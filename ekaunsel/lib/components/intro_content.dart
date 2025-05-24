import 'package:ekaunsel/utils/config.dart';
import 'package:flutter/material.dart';

 
class SplashContent extends StatefulWidget {
  const SplashContent({
    Key? key,
    this.text,
    this.image,
  }) : super(key: key);
  final String? text, image;

  @override
  State<SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Config.spaceSmall,
        const Text(
          "EKaunseling",
          style: TextStyle(
            fontSize: 35,
            color: Color.fromARGB(255, 255, 0, 0),
            fontWeight: FontWeight.bold,
          ),
        ),

        Config.spaceSmall,
        Image.asset(
          widget.image!,
          height: 265,
          width: 235,
        ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                            widget.text!,
                            textAlign: TextAlign.center,
                          ),
                ),
                
      ],
    );
  }
}
