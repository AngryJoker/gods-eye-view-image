FROM node:24.22.2-slim@sha256:c86ecead9e55a5210ac1727de38a4ca840bf03dcaf34dc9749addbf383b1920c
ENV PUPPETEER_SKIP_DOWNLOAD=1
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*
RUN git config --system --add safe.directory /app
WORKDIR /app
RUN chown node:node /app
USER node
COPY --chown=node:node package.json package-lock.json ./
RUN node -e "const fs=require('fs');const I='sha512-4enwjFfi4IwtEh0w+jPzpLVOFQiPHmmzPxcHXQOyEur47o6u0jE573DmGpjA+7irXoMLYRZD5ZaFUEneS3abPg==';const p=JSON.parse(fs.readFileSync('package.json'));if(p.devDependencies.vite!=='^6.4.4')throw 'pkg';p.devDependencies.vite='^6.4.5';fs.writeFileSync('package.json',JSON.stringify(p,null,2)+'\\n');const l=JSON.parse(fs.readFileSync('package-lock.json'));const r=l.packages[''],v=l.packages['node_modules/vite'];if(r.devDependencies.vite!=='^6.4.4'||v.version!=='6.4.4')throw 'lock';r.devDependencies.vite='^6.4.5';Object.assign(v,{version:'6.4.5',resolved:'https://registry.npmjs.org/vite/-/vite-6.4.5.tgz',integrity:I});fs.writeFileSync('package-lock.json',JSON.stringify(l,null,2)+'\\n');console.log('vite 6.4.5 aplicado')"
# cópia do lock depois do patch, para o CI mostrar o diff
RUN cp package-lock.json /tmp/package-lock.patched.json
RUN npm ci
RUN mkdir -p node_modules/.vite && chmod 777 node_modules node_modules/.vite
COPY --chown=node:node . .
# o COPY acima volta a trazer os package*.json do commit (o .dockerignore deixa o node_modules):
# o que conta é o vite instalado, que tem de ser o 6.4.5
RUN node -e "const v=require('./node_modules/vite/package.json').version;if(v!=='6.4.5')throw 'vite '+v;console.log('vite',v)"
ENV HOST=0.0.0.0
ENV PORT=4173
EXPOSE 4173
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 CMD ["node", "-e", "fetch('http://127.0.0.1:4173/').then((r)=>process.exit(r.ok?0:1),()=>process.exit(1))"]
CMD ["node", "scripts/docker-start.mjs"]
