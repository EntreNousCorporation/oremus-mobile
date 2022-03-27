import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageSlider extends StatelessWidget {
  const ImageSlider({Key? key, this.image}) : super(key: key);

  final image;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(0.0)),
          child: Stack(
            children: <Widget>[
              //Image.network(image, fit: BoxFit.cover, width: Get.width),
              Image.asset(image, fit: BoxFit.cover, width: Get.width,),
              Visibility(
                visible: true,
                child: Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(200, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                    child: const Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
