import 'package:flutter/material.dart';

Widget profileHeaderWidget(BuildContext context, username, profilePicUrl, int rentCount, int saleCount, int totalProperties) {
  return Container(
    width: double.infinity,
    decoration: const BoxDecoration(color: Colors.white),
    child: Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xff74EDED),
                backgroundImage: profilePicUrl.isNotEmpty
                    ? NetworkImage(profilePicUrl)
                    : const AssetImage('assets/default_profile.png') as ImageProvider,
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Text(
                        totalProperties.toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        "Properties",
                        style: TextStyle(
                          fontSize: 15,
                          letterSpacing: 0.4,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Column(
                    children: [
                      const Text(
                        "Rating",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < 3 ? Icons.star : Icons.star_border,
                            color: index < 3 ? Colors.amber : Colors.grey,
                            size: 20,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(width: 15),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            username,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          // const Text(
          //   "Lorem Ipsum",
          //   style: TextStyle(
          //     letterSpacing: 0.4,
          //   ),
          // ),
          // const SizedBox(
          //   height: 20,
          // ),
          // actions(context),
          const SizedBox(
            height: 20,
          ),
          // SizedBox(
          //   height: 85,
          //   child: ListView.builder(
          //     shrinkWrap: true,
          //     scrollDirection: Axis.horizontal,
          //     itemCount: highlightItems.length,
          //     itemBuilder: (context, index) {
          //       return Row(
          //         children: [
          //           Column(
          //             children: [
          //               CircleAvatar(
          //                 radius: 30,
          //                 backgroundColor: Colors.grey,
          //                 child: Padding(
          //                   padding: const EdgeInsets.all(2.0),
          //                   child: CircleAvatar(
          //                     backgroundImage:
          //                         AssetImage(highlightItems[index].thumbnail),
          //                     radius: 28,
          //                   ),
          //                 ),
          //               ),
          //               Padding(
          //                 padding: const EdgeInsets.only(top: 4),
          //                 child: Text(
          //                   highlightItems[index].title,
          //                   style: const TextStyle(fontSize: 13),
          //                 ),
          //               )
          //             ],
          //           ),
          //           const SizedBox(
          //             width: 10,
          //           )
          //         ],
          //       );
          //     },
          //   ),
          // )
        ],
      ),
    ),
  );
}

// Widget actions(BuildContext context) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Expanded(
//         child: OutlinedButton(
//           style: OutlinedButton.styleFrom(
//               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               minimumSize: const Size(0, 30),
//               side: BorderSide(
//                 color: Colors.grey[400]!,
//               )),
//           onPressed: () {},
//           child: const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 50),
//             child: Text("Edit Profile", style: TextStyle(color: Colors.black)),
//           ),
//         ),
//       ),
//     ],
//   );
// }
