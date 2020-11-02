import 'package:flutter/material.dart';
import 'summary_popup.dart';
class Summary extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SummaryGrid();
  }
}

class SummaryGrid extends StatefulWidget {
  const SummaryGrid({ Key key }) : super(key: key);

  @override
  SummaryGridState createState() => SummaryGridState();
}

class IconBox {
  IconBox({
    this.assetName,
    this.title,
    this.caption,
  });

  final String assetName;
  final String title;
  final String caption;

  String get tag => assetName; // Assuming that all asset names are unique.

  bool get isValid => assetName != null && title != null && caption != null;
}
class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(text),
    );
  }
}

class GridIconItem extends StatelessWidget {
  GridIconItem({
    Key key,
    @required this.iconBox,
  }) : assert(iconBox != null && iconBox.isValid),
       super(key: key);

  final IconBox iconBox;

  void showPhoto(BuildContext context) {
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(iconBox.title),
          ),
          body: SizedBox.expand(
            child: Hero(
              tag: iconBox.tag,
              child: SummaryPopup(category: iconBox.title),
            ),
          ),
        );
      }
    ));
  }

  @override
  Widget build(BuildContext context) {
    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: () { showPhoto(context); },
        child: Hero(
          key: Key(iconBox.assetName),
          tag: iconBox.tag,
          child: Image(
            image: AssetImage('icons/${iconBox.assetName}'),
            fit: BoxFit.cover,
          ),
        ),
      )
    );
    
    return GridTile(
      footer: GestureDetector(
        child: GridTileBar(
          backgroundColor: Colors.black26,
          title: _GridTitleText(iconBox.title),
          subtitle: _GridTitleText(iconBox.caption),
        ),
      ),
      child: image,
    );
  }
}

class SummaryGridState extends State<SummaryGrid> {

  List<IconBox> _icons = <IconBox>[
    IconBox(
      assetName: 'money-icons.png',
      title: 'Bills',
      caption: 'Housing, Utility, Phone',
    ),
    IconBox(
      assetName: 'debt.jpg',
      title: 'Debt',
      caption: 'Debt/Loan Repayment',
    ),
    IconBox(
      assetName: 'entertainment.png',
      title: 'Entertainment',
      caption: 'Fun Things',
    ),
    IconBox(
      assetName: 'food.png',
      title: 'Food',
      caption: 'Dining Out',
    ),
    IconBox(
      assetName: 'gasoline.png',
      title: 'Gas',
      caption: 'For the Car',
    ),
    IconBox(
      assetName: 'groceries.png',
      title: 'Groceries',
      caption: 'Food for the Week',
    ),
    IconBox(
      assetName: 'investments.png',
      title: 'Investment',
      caption: 'Save, Save, Save',
    ),
    IconBox(
      assetName: 'pets.png',
      title: 'Pets',
      caption: 'Pets',
    ),
    IconBox(
      assetName: 'home.png',
      title: 'Rent/Mortgage',
      caption: 'Rent/Mortgage Expenses'
    ),
    IconBox(
      assetName: 'other.png',
      title: 'Other',
      caption: 'Miscellaneous'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SafeArea(
            top: false,
            bottom: false,
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              childAspectRatio: 1.0,
              children: _icons.map<Widget>((IconBox icon) {
                return GridIconItem(
                    iconBox: icon,
                  );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}