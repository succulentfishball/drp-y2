import 'package:flutter/material.dart';

class PhotoWidget extends StatelessWidget {
  final String imageUrl;
  final String caption;
  final String datetime;
  final String user;

  const PhotoWidget({super.key, required this.imageUrl, required this.datetime, required this.user, this.caption = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  user,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.titleLarge?.fontSize, color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                Text(
                  datetime,
                  style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize, color: Theme.of(context).colorScheme.onPrimaryFixedVariant)
                ),
              ],
            )
          ),
          Center(
            child: SizedBox(
              // 80% of screen width
              // width: MediaQuery.of(context).size.width * 0.8,
              // full width
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          if (caption.isNotEmpty && caption != '') (
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: 
              Text(
                caption,
                style: TextStyle(fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize, color: Theme.of(context).colorScheme.onPrimaryContainer)
              ),
            )
          ),
        ],
      ),
    );
  }
}

class TimelineWidget extends StatefulWidget {
  const TimelineWidget({super.key, required this.photos});
  final List<PhotoWidget> photos;

  @override
  State<TimelineWidget> createState() => TimelineWidgetState();
}

class TimelineWidgetState extends State<TimelineWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        itemCount: widget.photos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: widget.photos[index]
          );
        },
      ),
    );
  }
}