import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:plan_for_all/models/task.dart';
import 'package:plan_for_all/services/task_service.dart';
import 'package:provider/provider.dart';

class TaskEditor extends StatefulWidget {
  final Task task;
  final VoidCallback onDismiss;

  const TaskEditor({super.key, required this.task, required this.onDismiss});

  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _markdownController = TextEditingController();
  Timer? _debounce;
  bool _isSaving = false;
  bool _isEditing = false;
  String _lastSaved = '';

  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.task.title;
    _markdownController.text = widget.task.description;
    _lastSaved = _markdownController.text;

    _titleController.addListener(_onChanged);
    _markdownController.addListener(_onChanged);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      final currentTitle = _titleController.text.trim();
      final currentDesc = _markdownController.text;
      final hasChanges = currentTitle != widget.task.title || currentDesc != _lastSaved;

      if (hasChanges) {
        setState(() => _isSaving = true);
        await context.read<TaskService>().updateTask(
          widget.task.id,
          currentTitle,
          currentDesc,
        );
        _lastSaved = currentDesc;
        widget.task.title = currentTitle; // 제목 변경 내용도 반영
        setState(() => _isSaving = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _markdownController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final editorHeight = isMobile
        ? MediaQuery.of(context).size.height * 0.5
        : MediaQuery.of(context).size.height * 0.7;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.translucent,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        SlideTransition(
          position: _offsetAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(20),
              height: editorHeight, // ← 여기 적용!
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: '제목을 입력하세요',
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => setState(() => _isEditing = !_isEditing),
                        icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
                        label: Text(_isEditing ? '미리보기' : '수정'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: _isEditing
                        ? KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) {
                        if (event is KeyDownEvent) {
                          final selection = _markdownController.selection;
                          final text = _markdownController.text;
                          final cursorPos = selection.baseOffset;
                          if (cursorPos == -1) return;

                          final start = cursorPos == 0 ? 0 : text.lastIndexOf('\n', cursorPos - 1) + 1;
                          final end = text.indexOf('\n', cursorPos);
                          final lineEnd = end == -1 ? text.length : end;

                          if (event.logicalKey == LogicalKeyboardKey.home) {
                            _markdownController.selection = TextSelection.collapsed(offset: start);
                          } else if (event.logicalKey == LogicalKeyboardKey.end) {
                            _markdownController.selection = TextSelection.collapsed(offset: lineEnd);
                          }
                        }
                      },
                      child: MarkdownField(
                        controller: _markdownController,
                        emojiConvert: true,
                        decoration: const InputDecoration.collapsed(hintText: ''),
                      ),
                    )
                        : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: Alignment.topLeft, // ✅ 왼쪽 정렬
                        child: MarkdownBody(
                          data: _markdownController.text,
                          softLineBreak: true,
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            p: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isSaving
                          ? Row(
                        key: const ValueKey('saving'),
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.sync, size: 16, color: Colors.orange),
                          SizedBox(width: 4),
                          Text('저장 중...', style: TextStyle(color: Colors.orange, fontSize: 12)),
                        ],
                      )
                          : Row(
                        key: const ValueKey('saved'),
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.cloud_done, size: 16, color: Colors.green),
                          SizedBox(width: 4),
                          Text('저장됨', style: TextStyle(color: Colors.green, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
