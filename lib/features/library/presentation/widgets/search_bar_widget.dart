import 'package:flutter/material.dart';
import 'filter_button.dart';

class SearchBarWidget
    extends StatelessWidget {

  const SearchBarWidget({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),

      child: Row(
        children: [

          Expanded(
            child: Container(
              height: 50,

              decoration:
              BoxDecoration(
                color: const Color(0xFFD9D4D9,),

                borderRadius:
                BorderRadius.circular(22,),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25,),

                    blurRadius: 12,
                    offset: const Offset(0, 5,),
                  ),
                ],
              ),

              child: const Row(
                children: [

                  SizedBox(width: 12,),

                  Icon(
                    Icons.search,
                    size: 40,
                    color: Colors.black54,
                  ),

                  SizedBox(width: 8,),

                  Text(
                    'Search',

                    style:
                    TextStyle(
                      color: Colors.black54,
                      fontSize: 24,
                      fontFamily: 'JosefinSlab',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10,),

          FilterButton(
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}