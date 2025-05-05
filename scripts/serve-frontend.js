const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = 3000;
const PUBLIC_DIR = path.join(__dirname, "../public");

// MIME types for common file extensions
const MIME_TYPES = {
  ".html": "text/html",
  ".css": "text/css",
  ".js": "text/javascript",
  ".json": "application/json",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".gif": "image/gif",
};

const server = http.createServer((req, res) => {
  console.log(`${req.method} ${req.url}`);
  
  // Handle root path
  let filePath = req.url === "/" 
    ? path.join(PUBLIC_DIR, "index.html") 
    : path.join(PUBLIC_DIR, req.url);
  
  // Get file extension
  const ext = path.extname(filePath);
  const contentType = MIME_TYPES[ext] || "text/plain";
  
  fs.readFile(filePath, (err, content) => {
    if (err) {
      if (err.code === "ENOENT") {
        // File not found
        console.log(`File not found: ${filePath}`);
        res.writeHead(404);
        res.end("File not found");
      } else {
        // Server error
        console.error(err);
        res.writeHead(500);
        res.end(`Server Error: ${err.code}`);
      }
    } else {
      // Success
      res.writeHead(200, { "Content-Type": contentType });
      res.end(content);
    }
  });
});

server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}/`);
  
  // Check for deployments.json
  const deploymentPath = path.join(PUBLIC_DIR, "deployments.json");
  if (fs.existsSync(deploymentPath)) {
    try {
      const deployData = JSON.parse(fs.readFileSync(deploymentPath));
      console.log("Contract deployed at:", deployData.contractAddress);
    } catch (err) {
      console.log("Error reading deployment data:", err.message);
    }
  } else {
    console.log("No deployment data found. Please deploy the contract first.");
  }
});
