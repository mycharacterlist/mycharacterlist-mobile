import 'package:flutter/material.dart';

class GradeRangeSlider extends StatefulWidget {

  const GradeRangeSlider({
    super.key,
  });

  @override
  State<GradeRangeSlider>
  createState() =>
      _GradeRangeSliderState();
}

class _GradeRangeSliderState extends State<GradeRangeSlider> {

  RangeValues values =
  const RangeValues(1, 10,);

  late TextEditingController minController;

  late TextEditingController maxController;

  @override
  void initState() {
    super.initState();

    minController = TextEditingController(text: '1',);

    maxController = TextEditingController(text: '10',);
  }

  void updateFromText() {

    double min =
        double.tryParse(
          minController.text,
        ) ?? 1;

    double max =
        double.tryParse(
          maxController.text,
        ) ?? 10;

    min = min.clamp(1, 10,);

    max = max.clamp(1, 10,);

    if (
    min > max
    ) {

      min = max;
    }

    setState(() {

      values =
          RangeValues(
            min, max,
          );
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Container(
      margin:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),

      padding:
      const EdgeInsets.all(15,),

      decoration:
      BoxDecoration(
        color: const Color(0xFFE9E9E9,),

        borderRadius:
        BorderRadius.circular(18,),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const Text(
            'Overall grade',

            style:
            TextStyle(
              fontSize: 32,
              fontFamily: 'JosefinSlab',
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15,),

          Row(
            children: [

              Expanded(
                child: TextField(
                  controller: minController,

                  keyboardType: TextInputType.number,

                  onChanged:
                      (_) =>
                      updateFromText(),

                  decoration:
                  InputDecoration(
                    labelText: 'Min',

                    filled: true,

                    fillColor: Colors.white,

                    border:
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12,),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12,),

              Expanded(
                child: TextField(
                  controller: maxController,

                  keyboardType: TextInputType.number,

                  onChanged:
                      (_) =>
                      updateFromText(),

                  decoration:
                  InputDecoration(
                    labelText: 'Max',

                    filled: true,

                    fillColor: Colors.white,

                    border:
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12,),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18,),

          RangeSlider(
            values: values,

            min: 1,
            max: 10,

            divisions: 9,

            labels:
            RangeLabels(
              values.start
                  .round()
                  .toString(),

              values.end
                  .round()
                  .toString(),
            ),

            onChanged:
                (newValues) {

              setState(() {

                values = newValues;

                minController.text =
                    newValues.start
                        .round()
                        .toString();

                maxController.text =
                    newValues.end
                        .round()
                        .toString();
              });
            },
          ),

          LayoutBuilder(
            builder:
                (context,
                constraints) {

              const double sliderPadding = 24;

              final width = constraints.maxWidth - sliderPadding * 2;

              final step = width / 9;

              return SizedBox(
                height: 22,

                child: Stack(
                  children:
                  List.generate(
                    10,
                        (index) {

                      return Positioned(
                        left: sliderPadding + step * index - 8,

                        child:
                        SizedBox(
                          width: 16,

                          child:
                          Center(
                            child:
                            Text(
                              '${index + 1}',

                              style:
                              const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontFamily: 'JosefinSlab',
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}