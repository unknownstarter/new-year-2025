import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_year_2025/core/models/user.dart';
import 'package:new_year_2025/core/providers/user_provider.dart';
import 'package:new_year_2025/core/providers/fortune_provider.dart';
import 'package:intl/intl.dart';

class UserInputForm extends StatefulWidget {
  const UserInputForm({super.key});

  @override
  State<UserInputForm> createState() => _UserInputFormState();
}

class _UserInputFormState extends State<UserInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _gender = '남성';
  DateTime _birthDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? '이름을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(
                labelText: '성별',
                border: OutlineInputBorder(),
              ),
              items: const ['남성', '여성']
                  .map((gender) =>
                      DropdownMenuItem(value: gender, child: Text(gender)))
                  .toList(),
              onChanged: (value) => setState(() => _gender = value!),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _birthDateTime,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_birthDateTime),
                  );

                  if (time != null) {
                    setState(() {
                      _birthDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '생년월일시',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(_birthDateTime),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('운세 보기'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final user = User(
        name: _nameController.text,
        gender: _gender,
        birthDateTime: _birthDateTime,
      );

      context.read<UserProvider>().setUser(user);
      context.read<FortuneProvider>().getFortune(user);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
