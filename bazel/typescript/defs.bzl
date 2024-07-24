load("@aspect_rules_ts//ts:defs.bzl", "ts_config", _ts_project = "ts_project")
load("@bazel_skylib//lib:paths.bzl", "paths")

def ts_project(
        name,
        tsconfig = None,
        srcs = None,
        deps = [":node_modules", "//:node_modules"],
        assets = None,
        out_dir = "dist",
        source_map = True,
        root_dir = "src",
        resolve_json_module = None,
        composite = True,
        declaration = True,
        declaration_map = True,
        validate = False,
        transpiler = "tsc",
        **kwargs):
    """
    A wrapper around the standard ts_project() macro from aspect_rules_ts.
    """

    ts_source_globs = ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.cts"]
    if resolve_json_module == True:
        ts_source_globs.append("**/*.json")

    if srcs == None:
        srcs = native.glob([paths.join(root_dir, glob) for glob in ts_source_globs]) + ["package.json"]

    if assets == None:
        assets = native.glob([paths.join(root_dir, "**")], exclude = ts_source_globs)

    if tsconfig == None:
        tsconfig = "{name}_tsconfig".format(name = name)
        ts_config(
            name = tsconfig,
            src = "tsconfig.json",
            deps = deps,
        )

    _ts_project(
        name = name,
        srcs = srcs,
        deps = deps,
        assets = assets,
        tsconfig = tsconfig,
        composite = composite,
        declaration = declaration,
        declaration_map = declaration_map,
        out_dir = out_dir,
        root_dir = root_dir,
        source_map = source_map,
        transpiler = transpiler,
        validate = validate,
        **kwargs
    )
