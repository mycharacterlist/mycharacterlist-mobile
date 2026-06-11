import 'package:flutter/material.dart';

class FilterBottomButtons extends StatelessWidget {

  final VoidCallback onClear;

  final VoidCallback onShow;

  const FilterBottomButtons({
    super.key,

    required this.onClear,

    required this.onShow,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),

      child: Row(
        children: [

          Expanded(
            child: Container(
              height: 50,

              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18,),

                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.black.withOpacity(0.2,),
                    blurRadius: 8,
                    offset: const Offset(0, 3,),
                  ),
                ],
              ),

              child: TextButton(
                onPressed: onClear,

                child: const Text(
                  'Clear filter',

                  style:
                  TextStyle(
                    color: Colors.black,
                    fontSize: 23,
                    fontFamily: 'JosefinSlab',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 18,),

          Expanded(
            child: Container(
              height: 50,

              decoration:
              BoxDecoration(
                color: Colors.black,

                borderRadius: BorderRadius.circular(18,),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25,),
                    blurRadius: 8,
                    offset: const Offset(0, 3,),
                  ),
                ],
              ),

              child: TextButton(
                onPressed: onShow,

                child: const Text(
                  'Show',

                  style:
                  TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontFamily: 'JosefinSlab',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}