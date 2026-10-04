const fs = require("node:fs");
const http = require("node:http");
const path = require("node:path");

const root = path.resolve(__dirname, "..", "web");
const port = Number(process.argv[2] || 8765);
const mimeTypes = {
	".html": "text/html; charset=utf-8",
	".js": "text/javascript; charset=utf-8",
	".json": "application/json; charset=utf-8",
	".manifest": "application/manifest+json",
	".png": "image/png",
	".pck": "application/octet-stream",
	".wasm": "application/wasm"
};

http.createServer((request, response) => {
	let relativePath;
	try {
		relativePath = decodeURIComponent(new URL(request.url, "http://localhost").pathname)
			.replace(/^\/+/, "") || "index.html";
	} catch {
		response.writeHead(400).end("Bad request");
		return;
	}

	const filePath = path.resolve(root, relativePath);
	if (!filePath.startsWith(root + path.sep)) {
		response.writeHead(403).end("Forbidden");
		return;
	}

	fs.stat(filePath, (statError, stats) => {
		if (statError || !stats.isFile()) {
			response.writeHead(404).end("Not found");
			return;
		}

		response.writeHead(200, {
			"Content-Type": mimeTypes[path.extname(filePath)] || "application/octet-stream",
			"Cache-Control": "no-store",
			"Service-Worker-Allowed": "/"
		});
		fs.createReadStream(filePath).pipe(response);
	});
}).listen(port, "127.0.0.1", () => {
	console.log(`Cat Cafe web preview: http://127.0.0.1:${port}/`);
	console.log("Serving only the exported web/ folder. Press Ctrl+C to stop.");
});
