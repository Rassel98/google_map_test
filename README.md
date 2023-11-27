# google_map_location

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



custom dropdown
DropdownButtonFormField<DropModel>(
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                iconSize: 40,
                iconDisabledColor: Colors.blue,
                iconEnabledColor: Colors.pink,
                decoration: InputDecoration(
                  fillColor: Colors.yellow,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 3,
                    ),
                  ),
                ),
                hint: const Text('Select your favourite fruit'),
                dropdownColor: Colors.greenAccent,
                value: controller.grop.value.title == null ? null : controller.grop.value,
                onChanged: (DropModel? newValue) {
                  controller.grop.value = newValue!;
                  print(newValue.title);
                },
                items: testList.isEmpty
                    ? null
                    : testList.map<DropdownMenuItem<DropModel>>((DropModel value) {
                        return DropdownMenuItem<DropModel>(
                          value: value,
                          child: Text(
                            value.title.toString(),
                          ),
                        );
                      }).toList(),
              ),
