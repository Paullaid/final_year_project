import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title,});

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController controller = TextEditingController();
  bool? isChecked = false;
  bool? isChecked1 = false;
  bool isSwitched = false;
  bool isSwitched1 = false;
  double sliderValue = 0.00;
  String? dropDownItem = "e1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  helperText: "Enter your Department",
                ),
                onEditingComplete: () {
                  setState(() {});
                },
              ),
              Text(controller.text),
              Checkbox.adaptive(
                tristate: true,
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value;
                  });
                },
              ),
              CheckboxListTile.adaptive(
                tristate: true,
                title: Text(
                  "Click Me",
                  style: TextStyle(color: Colors.blueAccent),
                ),
                value: isChecked1,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked1 = value;
                  });
                },
              ),
              Switch.adaptive(
                value: isSwitched,
                onChanged: (bool value) {
                  setState(() {
                    isSwitched = value;
                  });
                },
              ),
              SwitchListTile.adaptive(
                title: Text(
                  "Switch Me",
                  style: TextStyle(color: Colors.blueAccent),
                ),
                value: isSwitched1,
                onChanged: (value) {
                  setState(() {
                    isSwitched1 = value;
                  });
                },
              ),
              Slider(
                max: 50.0,
                value: sliderValue,
                divisions: 10,
                onChanged: (double value) {
                  setState(() {
                    sliderValue = value;
                  });
                },
              ),
              DropdownButton(
                value: dropDownItem,
                items: [
                  DropdownMenuItem(value: 'e1', child: Text("Item 1")),
                  DropdownMenuItem(value: 'e2', child: Text("Item 2")),
                  DropdownMenuItem(value: 'e3', child: Text("Item 3")),
                  DropdownMenuItem(value: 'e4', child: Text("Item 4")),
                  DropdownMenuItem(value: 'e5', child: Text("Item 5")),
                ],
                onChanged: (String? value) {
                  setState(() {
                    dropDownItem = value;
                  });
                },
              ),
              SizedBox(height: 15.0),
              GestureDetector(child: Image.asset("assets/images/img4.png")),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(foregroundColor: Colors.blue),
                child: Text("Login"),
              ),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.teal,
                  backgroundColor: const Color.fromARGB(255, 183, 243, 229),
                ),
                child: Text("Logout"),
              ),
              OutlinedButton(onPressed: () {}, child: Text("Notice")),
            ],
          ),
        ),
      ),
    );
  }
}
