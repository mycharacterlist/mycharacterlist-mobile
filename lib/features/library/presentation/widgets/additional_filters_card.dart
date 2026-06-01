import 'package:flutter/material.dart';

class AdditionalFiltersCard extends StatefulWidget {

  const AdditionalFiltersCard({
    super.key,
  });

  @override
  State<AdditionalFiltersCard>
  createState() =>
      _AdditionalFiltersCardState();
}

class _AdditionalFiltersCardState extends State<AdditionalFiltersCard> {

  final List<String> selectedGender = [];

  final List<String> selectedPosition = [];

  Widget buildCheckboxItem(
      String item,
      List<String> selected,
      ) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4,),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8,),

              child: Text(
                item,

                style:
                const TextStyle(
                  fontSize: 28,
                  fontFamily: 'JosefinSlab',
                ),
              ),
            ),
          ),

          Checkbox(
            value:
            selected.contains(item,),

            activeColor: Colors.black,

            onChanged:
                (value) {

              setState(() {

                if (value == true
                ) {

                  selected.add(item,);
                }

                else {

                  selected.remove(item,);
                }
              });
            },
          ),
        ],
      ),
    );
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

      padding: const EdgeInsets.all(15,),

      decoration:
      BoxDecoration(
        color: const Color(0xFFE9E9E9,),

        borderRadius: BorderRadius.circular(18,),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const Text(
            'Additional filters',

            style:
            TextStyle(
              fontSize: 32,
              fontFamily: 'JosefinSlab',
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20,),

          const Text(
            'Gender',

            style:
            TextStyle(
              fontSize: 28,
              fontFamily: 'JosefinSlab',
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8,),

          Row(
            children: [

              Expanded(
                child:
                buildCheckboxItem(
                  'Male',
                  selectedGender,
                ),
              ),

              Expanded(
                child:
                buildCheckboxItem(
                  'Female',
                  selectedGender,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20,),

          const Text(
            'Position',

            style:
            TextStyle(
              fontSize: 28,
              fontFamily: 'JosefinSlab',
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8,),

          buildCheckboxItem(
            '#1',
            selectedPosition,
          ),

          buildCheckboxItem(
            'Podium',
            selectedPosition,
          ),

          buildCheckboxItem(
            'In lists',
            selectedPosition,
          ),

          buildCheckboxItem(
            'Out of lists',
            selectedPosition,
          ),
        ],
      ),
    );
  }
}