import 'dart:async';
import 'dart:io';

class ProcessResultValue {
  const ProcessResultValue({
    required this.executable,
    required this.arguments,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.elapsed,
  });

  final String executable;
  final List<String> arguments;
  final int exitCode;
  final String stdout;
  final String stderr;
  final Duration elapsed;

  bool get succeeded => exitCode == 0;
}

class ProcessFailure implements Exception {
  const ProcessFailure(this.message, {this.result});

  final String message;
  final ProcessResultValue? result;

  @override
  String toString() => 'ProcessFailure: $message';
}

class SafeProcessRunner {
  const SafeProcessRunner({this.defaultTimeout = const Duration(seconds: 4)});

  final Duration defaultTimeout;

  Future<bool> exists(String executable) async {
    final String? path = Platform.environment['PATH'];
    if (path == null || executable.contains('/')) {
      return executable.contains('/') && await File(executable).exists();
    }
    for (final String directory in path.split(':')) {
      if (directory.isEmpty) {
        continue;
      }
      if (await File('$directory/$executable').exists()) {
        return true;
      }
    }
    return false;
  }

  Future<ProcessResultValue> run(
    String executable,
    List<String> arguments, {
    Duration? timeout,
    bool check = true,
    Map<String, String>? environment,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final Process process = await Process.start(
        executable,
        List<String>.unmodifiable(arguments),
        environment: environment,
        runInShell: false,
      );
      final Future<String> stdoutFuture = process.stdout
          .transform(const SystemEncoding().decoder)
          .join();
      final Future<String> stderrFuture = process.stderr
          .transform(const SystemEncoding().decoder)
          .join();
      final int exitCode = await process.exitCode.timeout(
        timeout ?? defaultTimeout,
        onTimeout: () {
          process.kill(ProcessSignal.sigterm);
          throw TimeoutException('$executable timed out');
        },
      );
      final ProcessResultValue result = ProcessResultValue(
        executable: executable,
        arguments: List<String>.unmodifiable(arguments),
        exitCode: exitCode,
        stdout: await stdoutFuture,
        stderr: await stderrFuture,
        elapsed: stopwatch.elapsed,
      );
      if (check && !result.succeeded) {
        throw ProcessFailure(
          '$executable exited with $exitCode: ${result.stderr.trim()}',
          result: result,
        );
      }
      return result;
    } on ProcessException catch (error) {
      throw ProcessFailure('Unable to start $executable: ${error.message}');
    } on TimeoutException catch (error) {
      throw ProcessFailure(error.message ?? '$executable timed out');
    } finally {
      stopwatch.stop();
    }
  }
}
