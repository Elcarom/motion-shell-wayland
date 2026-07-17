import 'dart:async';
import 'dart:io';

class CommandResult {
  const CommandResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String stdout;
  final String stderr;

  bool get succeeded => exitCode == 0;
}

class CommandTimeoutException implements Exception {
  const CommandTimeoutException({
    required this.executable,
    required this.arguments,
    required this.timeout,
    this.stdout = '',
    this.stderr = '',
  });

  final String executable;
  final List<String> arguments;
  final Duration timeout;
  final String stdout;
  final String stderr;

  @override
  String toString() {
    return '$executable did not respond within '
        '${timeout.inSeconds} seconds.';
  }
}

Future<CommandResult> runCommand(
  String executable,
  List<String> arguments, {
  Duration timeout = const Duration(seconds: 8),
  String? workingDirectory,
  Map<String, String>? environment,
}) async {
  final Process process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    environment: environment,
  );

  final Future<String> stdoutFuture = process.stdout
      .transform(systemEncoding.decoder)
      .join();
  final Future<String> stderrFuture = process.stderr
      .transform(systemEncoding.decoder)
      .join();

  try {
    final int exitCode = await process.exitCode.timeout(timeout);
    final List<String> output = await Future.wait<String>(<Future<String>>[
      stdoutFuture,
      stderrFuture,
    ]);

    return CommandResult(
      exitCode: exitCode,
      stdout: output[0],
      stderr: output[1],
    );
  } on TimeoutException {
    await _terminateProcess(process);

    final String stdout = await stdoutFuture.timeout(
      const Duration(seconds: 1),
      onTimeout: () => '',
    );
    final String stderr = await stderrFuture.timeout(
      const Duration(seconds: 1),
      onTimeout: () => '',
    );

    throw CommandTimeoutException(
      executable: executable,
      arguments: List<String>.unmodifiable(arguments),
      timeout: timeout,
      stdout: stdout,
      stderr: stderr,
    );
  }
}

Future<void> _terminateProcess(Process process) async {
  process.kill();

  try {
    await process.exitCode.timeout(const Duration(milliseconds: 350));
    return;
  } on TimeoutException {
    process.kill(ProcessSignal.sigkill);
  }

  try {
    await process.exitCode.timeout(const Duration(milliseconds: 350));
  } on TimeoutException {
    // The process is no longer awaited. SIGKILL has already been requested.
  }
}
