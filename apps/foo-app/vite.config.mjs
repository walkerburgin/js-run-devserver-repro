import { defineConfig } from "vite";

export default defineConfig(async (env) => {
    return {
        clearScreen: false,
        server: {
            port: 8080,
        },
    };
});

