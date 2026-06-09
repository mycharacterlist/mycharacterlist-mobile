import 'package:flutter/material.dart';

class AddCharacterButton extends StatelessWidget {

  const AddCharacterButton({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return Container(
      width: 75,
      height: 75,

      decoration:
      BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        gradient:
        const LinearGradient(
          begin: Alignment.topCenter,

          end: Alignment.bottomCenter,

          colors: [

            Color(0xFF4D1A8D),

            Color(0xFF24114D),
          ],
        ),

        boxShadow: const [

          BoxShadow(
            color: Colors.black38,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: const Icon(
        Icons.add,
        size: 50,
        color: Colors.blueAccent,
      ),
    );
  }
}