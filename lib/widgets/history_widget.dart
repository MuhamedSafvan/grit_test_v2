import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../hive/entries.dart';

class HistoryWidget extends StatelessWidget {
  const HistoryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Box<Entry> entryBox = Hive.box<Entry>('entries');

    return ValueListenableBuilder<Box<Entry>>(
      valueListenable: entryBox.listenable(),
      builder: (context, box, _) {
        final entryList = box.values.toList();
        entryList.sort((a, b) => b.time.compareTo(a.time));
        return entryList.isEmpty
            ? SizedBox()
            : Column(
                children: [
                  Text(
                    "History",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black,
                      child: ListView.builder(
                        itemCount: box.length,
                        itemBuilder: (context, index) {
                          final entry = entryList[index];
                          final formattedTimestamp = entry != null
                              ? DateFormat('dd-MM-yyyy HH:mm')
                                  .format(entry.time)
                              : '';

                          return ListTile(
                            title: Text(
                              entry.text ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Text(
                              formattedTimestamp,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
      },
    );
  }
}
