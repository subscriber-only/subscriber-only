#!/usr/bin/env node
import * as path from "path";

import * as esbuild from "esbuild";
import { Command } from "commander";
import { globSync as glob } from "glob";

const envPlugin = {
  name: 'env',
  setup(build) {
    // Intercept import paths called "env" so esbuild doesn't attempt
    // to map them to a file system location. Tag them with the "env-ns"
    // namespace to reserve them for this plugin.
    build.onResolve({ filter: /^env$/ }, args => ({
      path: args.path,
      namespace: 'env-ns',
    }));

    // Load paths tagged with the "env-ns" namespace and behave as if
    // they point to a JSON file containing the environment variables.
    build.onLoad({ filter: /.*/, namespace: 'env-ns' }, () => ({
      contents: JSON.stringify(process.env),
      loader: 'json',
    }));
  },
};

const globPlugin = {
  name: "glob",
  setup(build) {
    build.onResolve({ filter: /\*/ }, (args) => ({
      path: path.resolve(args.resolveDir, args.path),
      namespace: "glob-ns",
      pluginData: {
        path: args.path,
        resolveDir: args.resolveDir,
      }
    }));

    build.onLoad({ filter: /.*/, namespace: "glob-ns" }, (args) => {
      const { pluginData } = args;

      const files =
        glob(pluginData.path, { cwd: pluginData.resolveDir })
        .sort()
        .filter(path => /.+\..+/.test(path));

      const controllerNames = files.map((module) => module
        .replace(/_controller.[j|t]s$/, "")
        .replace(/\//g, "--")
        .replace(/_/g, '-'));

      let contents = "";
      for (let i = 0; i < files.length; ++i) {
        contents += `import * as module${i} from "./${files[i]}";`;
      }
      contents += "\nconst modules = [";
      for (let i = 0; i < controllerNames.length; ++i) {
        contents += `{
          name: '${controllerNames[i]}',
          module: module${i},
          filename: '${files[i]}'
        },`;
      }
      contents += "];\n";
      contents += "export default modules;";

      return { contents, resolveDir: pluginData.resolveDir };
    });
  }
};

const program = new Command();
program
  .argument("<entry points...>", "entry points")
  .requiredOption("-o, --outdir <outdir>", "output directory")
  .option("-m, --minify", "minify", false)
  .option("-w, --watch", "watch mode");
program.parse();
const options = program.opts();

const conf = {
  entryPoints: program.args,
  outdir: options.outdir,
  target: "es6",
  bundle: true,
  sourcemap: true,
  color: true,
  minify: options.minify,
  plugins: [envPlugin, globPlugin],
};

if (options.watch) {
  const ctx = await esbuild.context({ ...conf, logLevel: "info" });
  await ctx.watch();
} else {
  await esbuild.build(conf);
}
