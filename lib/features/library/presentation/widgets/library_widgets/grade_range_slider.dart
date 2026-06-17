import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';

import 'package:mycharacterlist/core/text/text_editing_utils.dart';

class GradeRangeSlider extends StatefulWidget {
  const GradeRangeSlider({
    super.key,
    this.initialValues = const RangeValues(0, 10),
    required this.onChanged,
  });

  final RangeValues initialValues;
  final ValueChanged<RangeValues> onChanged;

  @override
  State<GradeRangeSlider> createState() => _GradeRangeSliderState();
}

class _GradeRangeSliderState extends State<GradeRangeSlider> {
  late RangeValues values;

  late TextEditingController minController;

  late TextEditingController maxController;

  @override
  void initState() {
    super.initState();

    values = widget.initialValues;

    minController = TextEditingController(text: '${values.start.round()}');

    maxController = TextEditingController(text: '${values.end.round()}');
  }

  void updateFromText() {
    double min = double.tryParse(minController.text) ?? 0;

    double max = double.tryParse(maxController.text) ?? 10;

    min = min.clamp(0, 10);

    max = max.clamp(0, 10);

    if (min > max) {
      min = max;
    }

    setState(() {
      values = RangeValues(min, max);
    });
    widget.onChanged(values);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: AppColors.filterCard,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Overall grade',

            style: TextStyle(
              fontSize: 32,
              fontFamily: 'JosefinSlab',
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minController,

                  keyboardType: TextInputType.number,

                  onChanged: (_) => updateFromText(),

                  decoration: InputDecoration(
                    labelText: 'Min',

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black54),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: TextField(
                  controller: maxController,

                  keyboardType: TextInputType.number,

                  onChanged: (_) => updateFromText(),

                  decoration: InputDecoration(
                    labelText: 'Max',

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black54),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.deepPurple,
              inactiveTrackColor: Colors.deepPurple.withValues(alpha: 0.25),
              thumbColor: Colors.deepPurple,
              overlayColor: Colors.deepPurple.withValues(alpha: 0.12),
            ),
            child: RangeSlider(
            values: values,

            min: 0,
            max: 10,

            divisions: 10,

            labels: RangeLabels(
              values.start.round().toString(),

              values.end.round().toString(),
            ),

            onChanged: (newValues) {
              setState(() {
                values = newValues;

                setCollapsedControllerText(
                  minController,
                  newValues.start.round().toString(),
                );

                setCollapsedControllerText(
                  maxController,
                  newValues.end.round().toString(),
                );
              });
              widget.onChanged(newValues);
            },
            ),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              const double sliderPadding = 24;

              final width = constraints.maxWidth - sliderPadding * 2;

              final step = width / 10;

              return SizedBox(
                height: 22,

                child: Stack(
                  children: List.generate(11, (index) {
                    return Positioned(
                      left: sliderPadding + step * index - 8,

                      child: SizedBox(
                        width: 16,

                        child: Center(
                          child: Text(
                            '$index',

                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontFamily: 'JosefinSlab',
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
