# gods-eye-view-image

Builds a container image of [bilawalsidhu/gods-eye-view](https://github.com/bilawalsidhu/gods-eye-view) (MIT) from a pinned commit, with Vite 6.4.5 instead of 6.4.4. Personal homelab use. Not affiliated with the upstream project.

The build job has no secrets. It tests the image read-only, then a separate job publishes it to `ghcr.io/angryjoker/gods-eye-view`.
