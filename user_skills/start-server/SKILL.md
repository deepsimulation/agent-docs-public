---
name: start-server
description: Start the dev server in the background using the command from AGENTS.local.md, then monitor it. Use when the user says "start the server", "run the server", "launch the server", or similar.
disable-model-invocation: false
---

# Start Server

Start the dev server as a background process and monitor its startup.

## When to use

- User asks to start, run, or launch the dev server
- User says "start-server" or similar

## Steps

1. **Read `$FIREWORKS_DIR/AGENTS.local.md`** to get the current server command. The file contains the server launch command inside a bash code block. Extract the full command (environment variables + `python -m fireworks.serving.text_completion ...` with all flags).

2. **Check for existing GPU processes.** Before starting, check if anything is already using GPU memory. An existing server will cause CUDA OOM if you start a second one:

```bash
nvidia-smi --query-compute-apps=pid,used_gpu_memory,name --format=csv,noheader
```

Also check how many GPUs are available and how much memory is free:

```bash
nvidia-smi --query-gpu=index,memory.used,memory.total --format=csv,noheader
```

The full model requires **all 8 GPUs** with most of their memory free. If any GPU has significant memory in use (more than a few hundred MiB), the server will likely OOM during model loading.

If there are processes using GPU memory:
- **Tell the user** which PIDs are running, how much GPU memory they're using, and their process names.
- Tell them how many GPUs have significant memory in use vs. how many are needed.
- Ask if they want to kill them before proceeding.
- If the user confirms (or asked to "restart"), kill the PIDs: `kill <pid>`.
- Wait a few seconds and re-run `nvidia-smi` to verify GPU memory is freed before starting a new server.
- **Do NOT** start a new server while GPUs still have significant memory in use — it will OOM during model loading.

3. **Start the server using `nohup` + `tail -f`.** This is a two-part command run in a single Shell call with `block_until_ms: 0`:

```bash
source ~/.bashrc
cd $FIREWORKS_DIR
mkdir -p do_not_commit/server_logs
LOG_FILE=$FIREWORKS_DIR/do_not_commit/server_logs/server-$(date +%Y%m%d-%H%M%S).log
export VAR1=value1
export VAR2=value2
nohup python -m fireworks.serving.text_completion ... > $LOG_FILE 2>&1 &
echo "Server PID: $!"
tail -f $LOG_FILE
```

**IMPORTANT — environment variables:** The server command in `AGENTS.local.md` typically has inline environment variables like `VAR=val python -m ...`. You **must** convert these to separate `export VAR=val` lines **before** the `nohup` line. `nohup` does NOT support inline env vars — `nohup VAR=val cmd` tries to execute `VAR=val` as a binary and fails with "Permission denied".

**Why this pattern:** If you run the server command directly, Cursor removes the terminal from the UI when the process exits (e.g., crash or shutdown). By using `nohup`, the server output goes to a log file. `tail -f` keeps the terminal alive indefinitely (it never exits), so the terminal stays visible in Cursor's UI even if the server dies. You can always scroll up to see crash output.

4. **Monitor startup.** Poll the terminal file to monitor progress:
   - Read the terminal file immediately after launching
   - Sleep 5-10s between polls (server startup is slow — loading model weights, allocating KV cache, etc.)
   - Look for signs of successful startup such as `Uvicorn running on` or `Started server process`
   - Look for errors like `CUDA out of memory`, `RuntimeError`, tracebacks, or non-zero exit codes
   - Continue polling until the server is healthy or an error is detected (typically 2-5 minutes depending on model size and number of layers)

5. **Report status.** Tell the user:
   - Whether the server started successfully
   - The server PID (printed by the `echo` command above)
   - The URL the server is listening on (usually `http://localhost:80` or `http://localhost:8080`)

6. **Send a test request.** After the server is up, send a quick smoke test to verify it's working end-to-end:

```bash
python $FIREWORKS_DIR/scripts/completion.py --preset blue_sky --max-tokens=10
```

   - If it succeeds, report the result to the user.
   - If it fails, check the server logs for errors.

## Stopping the server

Kill using the server PID (NOT the `tail` PID):

```bash
kill <server_pid>
```

The `tail -f` process will remain running (keeping the terminal alive) so you can still see the final output. To also close the terminal, kill `tail` or press Ctrl+C in the terminal.

## Reading the log directly

You can also read the log file directly without the terminal. Log files are timestamped (e.g., `server-20260209-144500.log`):

```bash
# List available logs (most recent last)
ls -lt $FIREWORKS_DIR/do_not_commit/server_logs/

# Last 50 lines of most recent log
tail -50 $FIREWORKS_DIR/do_not_commit/server_logs/server-*.log | tail -50
```

## Load testing

If the user asks to run a load test, read `$FIREWORKS_DIR/docs/text_completion/load_testing.md` for instructions and configuration options.

**Run locust using the same `nohup` + `tail -f` pattern as the server.** This keeps the terminal alive in Cursor's UI even after locust finishes, so you can scroll up to see the final summary:

```bash
source ~/.bashrc
cd $FIREWORKS_DIR
mkdir -p do_not_commit/server_logs
LOG_FILE=$FIREWORKS_DIR/do_not_commit/server_logs/locust-$(date +%Y%m%d-%H%M%S).log
nohup locust -f $FIREWORKS_DIR/benchmark/llm_bench/load_test.py \
  <flags from AGENTS.local.md or docs/text_completion/load_testing.md> \
  > $LOG_FILE 2>&1 &
echo "Locust PID: $!"
tail -f $LOG_FILE
```

## Profiling

To capture a PyTorch profile while the server is under load:

```bash
mkdir -p do_not_commit/profiles
curl "http://localhost:80/profile?dir=$FIREWORKS_DIR/do_not_commit/profiles&num_steps=25&with_stack=false"
```

**Note:** After the curl returns, the profile files take a few seconds to appear on disk. Wait 5-10s before listing or uploading them.

- Use `num_steps=10` for a quick decode-only profile, `num_steps=25` for a wider window that may capture prefill.
- Profile files are written per-generator (e.g., `generator-0-0.<timestamp>.pt.trace.json`).
- View in https://ui.perfetto.dev/

## Notes

- The shell is **stateful within a conversation** but does **not** persist across conversations. A new conversation will need to restart the server.
- If the terminal file grows large, read from the end (use `offset: -100`) to get the latest output.
- If the server appears hung (no new output for >60s during startup), consider killing and restarting.
- The server command in `AGENTS.local.md` may change over time. Always read it fresh rather than hardcoding.
