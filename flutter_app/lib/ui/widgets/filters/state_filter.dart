import 'package:flutter/material.dart';
import 'package:flutter_app/models/project_model.dart';
import 'package:flutter_app/providers/project_filter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StateFilter extends ConsumerWidget {
  const StateFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedState = ref.watch(stateFilterProvider);

    return DropdownButtonFormField<EProjectState>(
      value: selectedState,
      decoration: InputDecoration(
        labelText: 'Filter State',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem<EProjectState>(
          value: null,
          child: Text('All States'),
        ),
        ...EProjectState.values.map((state) {
          return DropdownMenuItem<EProjectState>(
            value: state,
            child: Text(state.toString().split('.').last),
          );
        }),
      ],
      onChanged: (state) {
        ref.read(stateFilterProvider.notifier).state = state;
      },
    );
  }
}