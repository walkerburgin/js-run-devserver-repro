# js-run-devserver-repro

Run `pnpm dev` (or `ibazel run //apps/foo-app:dev`):

```console
  VITE v5.3.1  ready in 86 ms

  ➜  Local:   http://localhost:8080/
  ➜  Network: use --host to expose
  vite:resolve 0.24ms build/ts/App.js -> /private/var/folders/dt/89md32m53r31bbz6kn64qbl00000gp/T/js_run_devserver-WY0snwSqUrOq/_main/apps/foo-app/build/ts/App.js +0ms
  vite:resolve 0.49ms @monorepo/foo-lib -> /private/var/tmp/_bazel_wburgin/ffdb77af8205b613ce18a9eb21d677ca/execroot/_main/bazel-out/darwin_arm64-fastbuild/bin/pkgs/foo-lib/dist/index.js +1ms
```

Note that the `@monorepo/foo-lib` import is being resolved outside of the `js_run_devserver` sandbox.

Mechanically, the symlink in `_main/apps/foo-app/node_modules/@monorepo/foo-lib` that makes `@monorepo/foo-lib` visible to `@monorepo/foo-app` points outside of the `js_run_devserver` sandbox:

```console
➜  js-run-devserver-repro git:(master) ✗ realpath /private/var/folders/dt/89md32m53r31bbz6kn64qbl00000gp/T/js_run_devserver-Y5LNGqTTvt70/_main/apps/foo-app/node_modules/@monorepo/foo-lib
/private/var/tmp/_bazel_wburgin/ffdb77af8205b613ce18a9eb21d677ca/execroot/_main/bazel-out/darwin_arm64-fastbuild/bin/pkgs/foo-lib
```

So even though `//pkgs/foo-lib` files are copied into the sandbox, they aren't what the bundler sees.

```console
➜  js-run-devserver-repro git:(master) ✗ tree /private/var/folders/dt/89md32m53r31bbz6kn64qbl00000gp/T/js_run_devserver-Y5LNGqTTvt70/_main/
/private/var/folders/dt/89md32m53r31bbz6kn64qbl00000gp/T/js_run_devserver-Y5LNGqTTvt70/_main/
├── apps
│   └── foo-app
│       ├── build
│       │   └── ts
│       │       ├── App.js
│       │       └── App.js.map
│       ├── index.html
│       ├── node_modules
│       │   ├── @monorepo
│       │   │   └── foo-lib -> /var/folders/dt/89md32m53r31bbz6kn64qbl00000gp/T/js_run_devserver-Y5LNGqTTvt70/_main/node_modules/.aspect_rules_js/@monorepo+foo-lib@0.0.0/node_modules/@monorepo/foo-lib
│       │   └── vite -> /private/var/tmp/_bazel_wburgin/ffdb77af8205b613ce18a9eb21d677ca/execroot/_main/bazel-out/darwin_arm64-fastbuild/bin/apps/foo-app/node_modules/vite
│       ├── package.json
│       ├── src
│       │   └── App.tsx
│       └── vite.config.mjs
├── node_modules
│   ├── @bazel
│   │   └── ibazel -> /private/var/tmp/_bazel_wburgin/ffdb77af8205b613ce18a9eb21d677ca/execroot/_main/bazel-out/darwin_arm64-fastbuild/bin/node_modules/@bazel/ibazel
│   ├── ts-bazel-plugin -> /private/var/tmp/_bazel_wburgin/ffdb77af8205b613ce18a9eb21d677ca/execroot/_main/bazel-out/darwin_arm64-fastbuild/bin/node_modules/ts-bazel-plugin
│   ├── typescript -> /private/var/tmp/_bazel_wburgin/ffdb77af8205b613ce18a9eb21d677ca/execroot/_main/bazel-out/darwin_arm64-fastbuild/bin/node_modules/typescript
│   └── vite -> /private/var/tmp/_bazel_wburgin/ffdb77af8205b613ce18a9eb21d677ca/execroot/_main/bazel-out/darwin_arm64-fastbuild/bin/node_modules/vite
└── pkgs
    └── foo-lib
        ├── dist
        │   ├── index.d.ts
        │   ├── index.d.ts.map
        │   ├── index.js
        │   └── index.js.map
        ├── package.json
        └── tsconfig.json
```
