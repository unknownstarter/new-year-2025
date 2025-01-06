import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_year_2025/core/models/chat_message.dart';
import 'package:new_year_2025/core/models/user.dart';
import 'package:new_year_2025/core/providers/user_provider.dart';
import 'package:new_year_2025/core/providers/fortune_provider.dart';
import 'package:new_year_2025/presentation/widgets/chat_bubble.dart';
import 'package:lottie/lottie.dart';

class ChatInputForm extends StatefulWidget {
  const ChatInputForm({super.key});

  @override
  State<ChatInputForm> createState() => _ChatInputFormState();
}

class _ChatInputFormState extends State<ChatInputForm> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];
  String? _name;
  String? _gender;
  DateTime? _birthDateTime;
  bool _isAutoScrolling = false;

  @override
  void initState() {
    super.initState();
    _addInitialMessage();
    _scrollToBottom();
  }

  void _addInitialMessage() {
    _messages.add(
      ChatMessage(
        text: '안녕하세요! 2025년 운세를 알려드릴게요.\n먼저 이름을 알려주세요.',
        type: 'name',
        needsValidation: true,
      ),
    );
    setState(() {});
  }

  void _handleSubmit(String text) async {
    if (text.isEmpty) return;

    final currentText = text;

    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.unfocus();
    });

    setState(() {
      _messages.add(
          ChatMessage(text: currentText, isUser: true, userInput: currentText));
    });

    _scrollToBottom();

    final lastQuestion = _messages.lastWhere((m) => !m.isUser);

    switch (lastQuestion.type) {
      case 'name':
        if (text.length >= 2) {
          setState(() {
            _name = text;
            _messages.add(
              ChatMessage(
                text: '성별을 알려주세요. (남성/여성)',
                type: 'gender',
                needsValidation: true,
              ),
            );
          });
          _scrollToBottom();
        } else {
          _messages.add(
            ChatMessage(
              text: '이름을 다시 입력해주세요.',
              type: 'name',
              needsValidation: true,
            ),
          );
        }
        break;

      case 'gender':
        if (['남성', '여성'].contains(text)) {
          _gender = text;
          _messages.add(
            ChatMessage(
              text: '생년월일시를 알려주세요.\n(예시: 1996년 12월 1일 17시)',
              type: 'birthDateTime',
              needsValidation: true,
            ),
          );
        } else {
          _messages.add(
            ChatMessage(
              text: '성별을 남성 또는 여성으로 입력해주세요.',
              type: 'gender',
              needsValidation: true,
            ),
          );
        }
        break;

      case 'birthDateTime':
        try {
          _birthDateTime = _parseBirthDateTime(text);
          final user = User(
            name: _name!,
            gender: _gender!,
            birthDateTime: _birthDateTime!,
          );

          context.read<UserProvider>().setUser(user);

          setState(() {
            _messages.add(
              ChatMessage(
                text: '잠시만 기다려주세요. 운세를 분석하고 있습니다...',
                type: 'loading',
              ),
            );
          });

          _scrollToBottom();

          try {
            final result =
                await context.read<FortuneProvider>().getFortune(user);

            setState(() {
              // 로딩 메시지 제거
              _messages.removeWhere((m) => m.type == 'loading');

              // 운세 결과를 채팅 메시지로 추가
              _messages.add(ChatMessage(
                text: '${user.name}님의 2025년 운세입니다.',
                type: 'system',
              ));

              // 각 섹션을 개별 메시지로 표시
              final sections = [
                result['overall'],
                result['love'],
                result['money'],
                result['health'],
                result['career'],
                result['quarterly'],
              ];

              // null이 아닌 섹션만 표시
              for (final section in sections) {
                if (section != null && section.isNotEmpty) {
                  _messages.add(ChatMessage(
                    text: section,
                    type: 'fortune',
                  ));
                }
              }

              _messages.add(ChatMessage(
                text:
                    '운세 보기가 완료되었습니다. 운세 결과 내용이나 저와 관련한 피드백이 있다면 \'피드백\'을 입력해주세요!\n(운세 다시보기는 왼쪽 위에 있는 뒤로 가기를 이용해주세요.)',
                type: 'complete',
              ));
            });

            _scrollToBottom();
          } catch (e) {
            setState(() {
              _messages.add(ChatMessage(
                text: '죄송합니다. 운세를 가져오는 중에 문제가 발생했습니다. 다시 시도해주세요.',
                type: 'error',
              ));
            });
          }
        } catch (e) {
          _messages.add(
            ChatMessage(
              text: '생년월일시 형식이 올바르지 않습니다.\n다시 입력해주세요.',
              type: 'birthDateTime',
              needsValidation: true,
            ),
          );
        }
        break;

      case 'complete':
        if (text.trim() == '피드백') {
          setState(() {
            _messages.add(ChatMessage(
              text: '운세 내용이나 제게 해주실 얘기가 있다면 알래 버튼을 눌러 피드백을 남겨주세요 :)',
              type: 'feedback',
            ));
            _messages.add(ChatMessage(
              text:
                  'https://docs.google.com/forms/d/e/1FAIpQLScskPklW4-i7nEsQnG5rrbFYoDUFYZ1pPQ6fZj3IYMaYBBlkw/viewform?usp=dialog',
              type: 'link',
            ));
          });
        }
        break;
    }

    _scrollToBottom();
  }

  DateTime _parseBirthDateTime(String input) {
    final regex = RegExp(r'(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일\s*(\d{1,2})시');
    final match = regex.firstMatch(input);

    if (match == null) throw FormatException('Invalid date format');

    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _isAutoScrolling = true;
        _scrollController
            .animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            )
            .whenComplete(() => _isAutoScrolling = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (!_isAutoScrolling &&
                      notification is UserScrollNotification) {
                    _focusNode.unfocus();
                  }
                  return true;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ChatBubble(message: message),
                    );
                  },
                ),
              ),
              // 로딩 오버레이
              if (_messages.any((m) => m.type == 'loading'))
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Lottie.asset(
                            'assets/animations/fortune_animation.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '운세를 분석하고 있습니다...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: MediaQuery.of(context).viewInsets.bottom > 0
              ? const EdgeInsets.all(8)
              : EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 8,
                  bottom: 8 + MediaQuery.of(context).padding.bottom,
                ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: '메시지를 입력하세요',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: _handleSubmit,
                  key: const Key('chat_input'),
                  textInputAction: TextInputAction.done,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _handleSubmit(_controller.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
