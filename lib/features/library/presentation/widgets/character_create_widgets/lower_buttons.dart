import 'package:flutter/material.dart';

class LowerButtons extends StatelessWidget {

  const LowerButtons({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [

        SizedBox(
          width: 130,
          height: 45,

          child: ElevatedButton(
            onPressed: () {},

            style:
            ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E2E00,),
              foregroundColor: Colors.white,
              elevation: 4,

              shape:
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),

            child: const Text(
              'Clear all',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'JosefinSlab',
              ),
            ),
          ),
        ),

        SizedBox(
          width: 130,
          height: 45,

          child: ElevatedButton(
            onPressed: () {},

            style:
            ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF444444,),

              foregroundColor:
              Colors.white,
              elevation: 4,

              shape:
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),

            child: const Text(
              'Create',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'JosefinSlab',
              ),
            ),
          ),
        ),
      ],
    );
  }
}