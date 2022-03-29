# puppeteer-alpine-docker-aws
Use Puppeteer in a Docker container using Alpine Linux with a ~/.aws directory

## Requirements

- Docker version 20 or later
- This does not work on MacOS with Apple processors! Even with `--platform=linux,` Chromium crashes upon starting with an error about ptrace

## Dockerfile Arguments

- GROUPID - Defaults to 1000
- USERID - Defaults to 1000

## Building the Image

1. Modify build.sh per your needs
2. `build.sh`

## Running a Shell in the Container

`docker run --init --shm-size=1gb -it terrisgit-alpine-puppeteer ash`

In the shell, run 'chromium-browser'. You should see the following output:

```
Failed to move to new namespace: PID namespaces supported, Network namespace supported, but failed: errno = Operation not permitted
[0329/165712.750711:WARNING:process_reader_linux.cc(76)] sched_getscheduler: Function not implemented (38)
[0329/165712.750858:WARNING:process_reader_linux.cc(76)] sched_getscheduler: Function not implemented (38)
[0329/165712.751098:ERROR:file_io_posix.cc(144)] open /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq: No such file or directory (2)
[0329/165712.751154:ERROR:file_io_posix.cc(144)] open /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq: No such file or directory (2)
Trace/breakpoint trap
/app $ [17:17:0100/000000.782930:ERROR:zygote_linux.cc(646)] write: Broken pipe (32)
```
