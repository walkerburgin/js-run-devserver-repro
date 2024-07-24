load("@aspect_rules_js//js:defs.bzl", "js_library", "js_run_devserver")
load("@npm//:defs.bzl", "npm_link_all_packages")
load("@npm//:vite/package_json.bzl", vite = "bin")
load("//bazel/typescript:defs.bzl", "ts_project")

def library_npm_package():
    name = Label("//" + native.package_name()).name

    npm_link_all_packages(name = "node_modules")

    ts_project(
        name = "typescript",
        out_dir = "dist",
    )

    js_library(
        name = name,
        srcs = [
            "package.json",
            ":typescript",
        ],
        data = [":node_modules"],
        visibility = ["//visibility:public"],
    )

def bundle_npm_package():
    name = Label("//" + native.package_name()).name

    npm_link_all_packages(name = "node_modules")

    ts_project(
        name = "typescript",
        out_dir = "build/ts",
    )

    vite.vite(
        name = "dist",
        srcs = ["package.json", ":typescript", "vite.config.mjs", "index.html"],
        chdir = native.package_name(),
        args = [
            "build",
            "--config",
            "vite.config.mjs",
            "-m",
            "production",
        ],
        env = {
            "DEBUG": "vite:resolve",
            "FORCE_COLOR": "1",
            # "JS_BINARY__LOG_INFO": "1",
            # "JS_BINARY__LOG_DEBUG": "1",
        },
        out_dirs = ["dist"],
        silent_on_success = False,
        visibility = ["//visibility:public"],
    )

    vite.vite_binary(name = "vite_bin")

    js_run_devserver(
        name = "dev",
        data = ["package.json", ":typescript", "vite.config.mjs", "index.html"] + native.glob(["src/**"]),
        chdir = native.package_name(),
        args = [
            "--config",
            "vite.config.mjs",
        ],
        env = {
            "DEBUG": "vite:resolve",
            "FORCE_COLOR": "1",
            # "JS_BINARY__LOG_INFO": "1",
            # "JS_BINARY__LOG_DEBUG": "1",
        },
        tool = ":vite_bin",
        visibility = ["//visibility:public"],
    )

    js_run_devserver(
        name = "preview",
        data = ["dist", "vite.config.mjs", ":typescript"],
        chdir = native.package_name(),
        args = [
            "preview",
            "--config",
            "vite.config.mjs",
        ],
        env = {
            "DEBUG": "vite:resolve",
            "FORCE_COLOR": "1",
            # "JS_BINARY__LOG_INFO": "1",
            # "JS_BINARY__LOG_DEBUG": "1",
        },
        tool = ":vite_bin",
        visibility = ["//visibility:public"],
    )

    js_library(
        name = name,
        srcs = [
            "package.json",
            ":dist",
        ],
        data = [":node_modules"],
        visibility = ["//visibility:public"],
    )
