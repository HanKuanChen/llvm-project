//===-- ExecuteFunction implementation for Unix-like Systems --------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "ExecuteFunction.h"
#include "src/__support/macros/config.h"
#include "test/UnitTest/ExecuteFunction.h" // FunctionCaller
#include <assert.h>
#include <poll.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

namespace LIBC_NAMESPACE_DECL {
namespace testutils {

bool ProcessStatus::exited_normally() { return WIFEXITED(platform_defined); }

int ProcessStatus::get_exit_code() {
  assert(exited_normally() && "Abnormal termination, no exit code");
  return WEXITSTATUS(platform_defined);
}

int ProcessStatus::get_fatal_signal() {
  if (exited_normally())
    return 0;
  return WTERMSIG(platform_defined);
}

ProcessStatus invoke_in_subprocess(FunctionCaller *func, int timeout_ms) {
  int pipe_fds[2];
  if (::pipe(pipe_fds) == -1) {
    delete func;
    return ProcessStatus::error("pipe(2) failed");
  }

  // Don't copy the buffers into the child process and print twice.
  ::fflush(stderr);
  ::fflush(stdout);
  pid_t pid = ::fork();
  if (pid == -1) {
    delete func;
    return ProcessStatus::error("fork(2) failed");
  }

  if (!pid) {
    (*func)();
    delete func;
    ::exit(0);
  }
  ::close(pipe_fds[1]);

  struct pollfd poll_fd {
    pipe_fds[0], 0, 0
  };
  // No events requested so this call will only return after the timeout or if
  // the pipes peer was closed, signaling the process exited.
  if (::poll(&poll_fd, 1, timeout_ms) == -1) {
    delete func;
    return ProcessStatus::error("poll(2) failed");
  }
  // If the pipe wasn't closed by the child yet then timeout has expired.
  if (!(poll_fd.revents & POLLHUP)) {
    ::kill(pid, SIGKILL);
    delete func;
    return ProcessStatus::timed_out_ps();
  }

  int wstatus = 0;
  // Wait on the pid of the subprocess here so it gets collected by the system
  // and doesn't turn into a zombie.
  pid_t status = ::waitpid(pid, &wstatus, 0);
  if (status == -1) {
    delete func;
    return ProcessStatus::error("waitpid(2) failed");
  }
  assert(status == pid);
  delete func;
  return {wstatus};
}

const char *signal_as_string(int signum) { return ::strsignal(signum); }

} // namespace testutils
} // namespace LIBC_NAMESPACE_DECL
