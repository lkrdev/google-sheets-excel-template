.PHONY: dev-tunnel
dev-tunnel:
	@bash -c '\
		if ! command -v cloudflared &> /dev/null && [ ! -f ./cloudflared ]; then \
			echo "cloudflared not found. Downloading standalone linux-amd64 binary..."; \
			curl -L --output ./cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64; \
			chmod +x ./cloudflared; \
		fi; \
		CLOUDFLARED=$$(command -v cloudflared || echo "./cloudflared"); \
		echo "Launching Cloudflare Tunnel..."; \
		rm -f cloudflared.log; \
		$$CLOUDFLARED tunnel --url http://localhost:8080 > cloudflared.log 2>&1 & cloudflared_pid=$$!; \
		echo "Waiting for Cloudflare to generate tunnel URL..."; \
		URL=""; \
		for i in {1..30}; do \
			sleep 1; \
			URL=$$(grep -o -m 1 "https://[a-zA-Z0-9.-]*\.trycloudflare\.com" cloudflared.log 2>/dev/null || true); \
			if [ -n "$$URL" ]; then break; fi; \
		done; \
		if [ -z "$$URL" ]; then \
			echo "Failed to generate tunnel URL. Here is the end of cloudflared.log:"; \
			tail -n 10 cloudflared.log; \
			kill $$cloudflared_pid 2>/dev/null; \
			exit 1; \
		fi; \
		echo "Starting dev server with ACTION_HUB_BASE_URL=$$URL..."; \
		ACTION_HUB_BASE_URL=$$URL yarn dev > dev-server.log 2>&1 & dev_pid=$$!; \
		echo "Waiting for dev server to start..."; \
		sleep 3; \
		echo ""; \
		echo "=================================================="; \
		echo "  GOOGLE SHEETS EXCEL TEMPLATE ACTION HUB"; \
		echo "=================================================="; \
		echo " Dev Server Log:  dev-server.log"; \
		echo " Cloudflared Log: cloudflared.log"; \
		echo "--------------------------------------------------"; \
		echo " Public Access URL:"; \
		echo " $$URL"; \
		echo " OAuth Redirect URI:"; \
		echo " $$URL/actions/google-sheet-xlsx-template/oauth_redirect"; \
		echo "=================================================="; \
		echo "Press Ctrl+C to stop both servers."; \
		echo ""; \
		trap "kill $$dev_pid $$cloudflared_pid 2>/dev/null; exit" INT TERM EXIT; \
		wait \
	'
