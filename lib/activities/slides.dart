import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Slides extends StatefulWidget {
  const Slides({Key? key, required this.data, required this.activityCallback})
      : super(key: key);
  final Map data;
  final Function activityCallback;
  @override
  State<Slides> createState() => _SlidesState();
}

class _SlidesState extends State<Slides> with TickerProviderStateMixin {
  int index = 0;
  late List list;

  @override
  void initState() {
    String str = widget.data['text'];
    List arr = str.split('\n').map((e) => e.trim()).toList();
    final reg = RegExp(r'\s*\|\s*');
    list = arr
        .map((item) => item.split(reg))
        // .map((e) => ({'img': e[0].trim(), 'text': e[1].trim()})))
        .toList();
    // list = list.sublist(0, 8);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: CoolSwiper(
              activityCallback: widget.activityCallback,
              audio: widget.data['audio'],
              audioOffset: widget.data['audioOffset'] ?? 0,
              children: List.generate(
                list.length,
                (index) => CardContent(
                    color: Data.colors[index % Data.colors.length],
                    data: list[index]),
              ),
            )),
      ),
    );
  }
}

// borrowed code - begin

class CoolSwiper extends StatefulWidget {
  final List<Widget> children;
  final double initAnimationOffset;
  final double cardHeight;
  final Function activityCallback;
  final String audio;
  final int audioOffset;
  const CoolSwiper({
    Key? key,
    required this.audio,
    required this.audioOffset,
    required this.children,
    required this.activityCallback,
    this.initAnimationOffset = Constants.initAnimationOffset,
    this.cardHeight = Constants.cardHeight,
  }) : super(key: key);

  @override
  State<CoolSwiper> createState() => _CoolSwiperState();
}

class _CoolSwiperState extends State<CoolSwiper>
    with SingleTickerProviderStateMixin {
  late AudioPlayer player;
  late final AnimationController backgroundCardsAnimationController;
  int index = 0;
  late final List<Widget> stackChildren;
  final ValueNotifier<bool> _backgroundCardsAreInFrontNotifier =
      ValueNotifier<bool>(false);
  bool fireBackgroundCardsAnimation = false;

  late final List<SwiperCard> _cards;
  List<Widget> get _stackChildren => List.generate(
        _cards.length,
        (i) {
          return CoolSwiperCard(
            key: ValueKey('__animated_card_${i}__'),
            card: _cards[i],
            height: widget.cardHeight,
            initAnimationOffset: widget.initAnimationOffset,
            onAnimationTrigger: _onAnimationTrigger,
            onVerticalDragEnd: () {},
          );
        },
      );

  void _onAnimationTrigger() async {
    setState(() {
      fireBackgroundCardsAnimation = true;
    });
    backgroundCardsAnimationController.forward();
    Future.delayed(Constants.backgroundCardsAnimationDuration).then(
      (_) {
        _backgroundCardsAreInFrontNotifier.value = true;
      },
    );
    Future.delayed(Constants.swipeAnimationDuration).then(
      (_) {
        _backgroundCardsAreInFrontNotifier.value = false;
        backgroundCardsAnimationController.reset();
        _swapLast();
      },
    );
  }

  void _swapLast() async {
    Widget last = stackChildren[stackChildren.length - 1];
    widget.activityCallback({
      'type': 'progress',
      'progress': ((index + 1) / stackChildren.length * 100).ceil()
    });

    setState(() {
      stackChildren.removeLast();
      stackChildren.insert(0, last);
      index += 1;
    });
    if (index < stackChildren.length) {
      playaudio();
    }
  }

  void playaudio() async {
    await player.setClip(
        start: Duration(seconds: widget.audioOffset + (index) * 2),
        end: Duration(seconds: widget.audioOffset + (index) * 2 + 2));
    await player.play();
  }

  @override
  void initState() {
    super.initState();
    _cards = SwiperCard.listFromWidgets(widget.children);
    stackChildren = _stackChildren;
    backgroundCardsAnimationController = AnimationController(
      vsync: this,
      duration: Constants.backgroundCardsAnimationDuration,
    );
    // String audio = widget.audio.replaceAll('.mp3', '.aac');
    player = AudioPlayer();
    player.setAsset('assets/sound/${widget.audio}');
    playaudio();
    //player.setAsset('assets/sound/ta/ta-animals-birds-bodyparts-1.aac');
  }

  @override
  void dispose() {
    backgroundCardsAnimationController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (index >= _cards.length) {
      return Column(children: [
        Text('You have completed this activity.',
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 25)),
        ElevatedButton(
            onPressed: () {
              widget.activityCallback({
                'type': 'complete',
                'response': {'done': true}
              });
            },
            child: Text('Next'))
      ]);
    }
    return Stack(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Move the cards and remember the picture, sound and the word.',
              textAlign: TextAlign.start),
          SizedBox(height: 20),
          GestureDetector(
              onTap: playaudio,
              child: Row(children: [
                Text('Repeat'),
                Icon(
                  Icons.volume_up,
                  color: Colors.black,
                  size: 20.0,
                )
              ])),
        ]),
        ValueListenableBuilder(
          valueListenable: _backgroundCardsAreInFrontNotifier,
          builder: (c, bool backgroundCardsAreInFront, _) =>
              backgroundCardsAreInFront
                  ? Positioned(child: Container())
                  : _buildBackgroundCardsStack(),
        ),
        _buildFrontCard(),
        ValueListenableBuilder(
          valueListenable: _backgroundCardsAreInFrontNotifier,
          builder: (c, bool backgroundCardsAreInFront, _) =>
              backgroundCardsAreInFront
                  ? _buildBackgroundCardsStack()
                  : Positioned(child: Container()),
        ),
      ],
    );
  }

  Widget _buildBackgroundCardsStack() {
    return Stack(
      children: List.generate(
        _cards.length - 1,
        (i) => _buildStackChild(i),
      ),
    );
  }

  Widget _buildFrontCard() {
    return _buildStackChild(_cards.length - 1);
  }

  Widget _buildStackChild(int i) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: i != stackChildren.length - 1,
        child: CoolSwiperCardWrapper(
          animationController: backgroundCardsAnimationController,
          initialScale: _cards[i].scale,
          initialYOffset: _cards[i].yOffset,
          child: stackChildren[i],
        ),
      ),
    );
  }
}

/// This is the widget responsible for user drag & release animations
///
/// It also sends drag information to root stack widget
class CoolSwiperCard extends StatefulWidget {
  final SwiperCard card;
  final Function onAnimationTrigger;
  final Function onVerticalDragEnd;
  final double height;
  final double initAnimationOffset;

  const CoolSwiperCard({
    Key? key,
    required this.card,
    required this.onAnimationTrigger,
    required this.onVerticalDragEnd,
    required this.height,
    required this.initAnimationOffset,
  }) : super(key: key);

  @override
  State<CoolSwiperCard> createState() => _CoolSwiperCardState();
}

class _CoolSwiperCardState extends State<CoolSwiperCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  late final Animation<double> rotationAnimation;
  late final Animation<double> slideUpAnimation;
  late final Animation<double> slideDownAnimation;
  late final Animation<double> scaleAnimation;

  Tween<double> rotationAnimationTween = Tween<double>(begin: 0, end: -360);
  Tween<double> slideDownAnimationTween = Tween<double>(begin: 0, end: 0);

  double yDragOffset = 0;
  double dragStartAngle = 0;
  Alignment dragStartRotationAlignment = Alignment.centerRight;
  Duration dragDuration = const Duration(milliseconds: 0);

  /// When the drag starts, the card rotates a small angle
  /// with an alignment based on the touch/click location of the user
  ///
  /// And the main flying rotation tween gets its end value based on the
  /// touch/click location as well to determine whether the flying flip will
  /// happen with a negative or positive angle
  void _onVerticalDragStart(DragStartDetails details) {
    double screenWidth = MediaQuery.of(context).size.width;

    final xPosition = details.globalPosition.dx;
    final yPosition = details.localPosition.dy;
    final angleMultiplier = xPosition > screenWidth / 2 ? -1 : 1;
    rotationAnimationTween.end =
        Constants.rotationAnimationAngleDeg * angleMultiplier;

    // Update values of the small angle drag start rotation animation
    setState(() {
      dragStartRotationAlignment = getDragStartPositionAlignment(
        xPosition,
        yPosition,
        screenWidth,
        widget.height,
      );
      dragStartAngle = Constants.dragStartEndAngle * angleMultiplier;
      // If the drag duration is larger than zero, rest to zero
      // to allow the card to move with user finger/mouse smoothly
      if (dragDuration > Duration.zero) {
        dragDuration = Duration.zero;
      }
    });
  }

  /// When the drag ends, first a check is made to ensure the card travelled some
  /// offset distance upwards,
  /// if it didn't, the cards returns to place
  /// if it did, the animation is triggered by
  ///   - calling a callback to the parent widget
  ///   - changing the end value of the slide down animation tween
  ///     based on how much distance the card travelled
  ///   - calling forward() on the animation controller
  ///
  /// After the animation finishes, a callback to the parent widget is
  /// called to let it know that it can swap the background cards and brings
  /// them forward to reset the indices and allow for the next card to be dragged & animated
  void _onVerticalDragEnd(DragEndDetails details) {
    if ((yDragOffset * -1) > widget.initAnimationOffset) {
      widget.onAnimationTrigger();
      slideDownAnimationTween.end = Constants.throwSlideYDistance +
          yDragOffset.abs() -
          (widget.card.totalCount - 1) * Constants.yOffset;

      animationController.forward().then((value) {
        widget.onVerticalDragEnd();
        setState(() {
          dragStartAngle = 0;
        });
      });
    } else {
      setState(() {
        // Set a non-zero drag rotation to allow the card to reset to original
        // position smoothly rather than snapping back into place
        dragDuration = const Duration(milliseconds: 200);
        yDragOffset = 0;
        dragStartAngle = 0;
      });
    }
  }

  /// This moves the card with user touch/click & hold
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      yDragOffset += details.delta.dy;
    });
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Constants.swipeAnimationDuration,
    );

    rotationAnimation = rotationAnimationTween.animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    scaleAnimation = Tween<double>(
      begin: 1,
      end: 1 - ((widget.card.totalCount - 1) * Constants.scaleFraction),
    ).animate(animationController);

    // Staggered animation is used here to allow
    // sequencing the slide up & slide down animations
    slideUpAnimation = Tween<double>(
      begin: 0,
      end: -Constants.throwSlideYDistance,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0, 0.5, curve: Curves.linear),
    ));

    slideDownAnimation = slideDownAnimationTween.animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.5, 1, curve: Curves.linear),
    ));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: yDragOffset),
        duration: dragDuration,
        curve: Curves.easeOut,
        // This TweenAnimationBuilder widget is responsible for the user
        // touch/click & hold dragging
        // Or the DRAG UPDATE ANIMATION
        builder: (c, double value, child) => Transform.translate(
          offset: Offset(0, value),
          child: child,
        ),
        child: AnimatedBuilder(
          animation: animationController,
          // This widgets is responsible for the small angle rotation
          // triggered on user touch/click & hold
          // Or the DRAG START ANIMATION
          child: AnimatedRotation(
            turns: dragStartAngle,
            alignment: dragStartRotationAlignment,
            duration: const Duration(milliseconds: 200),
            child: widget.card.child,
          ),
          builder: (c, child) {
            // This widgets inside the builder method of the AnimatedBuilder
            // widget are responsible for the:
            // slide-up => rotation => slide-down animations
            // Or the DRAG END ANIMATION
            return Transform.translate(
              // slide up some distance beyond drag location
              offset: Offset(0, slideUpAnimation.value),
              child: Transform.translate(
                // slide down into place
                offset: Offset(0, slideDownAnimation.value),
                child: Transform.rotate(
                  // rotate
                  angle: rotationAnimation.value * (math.pi / 180),
                  alignment: Alignment.center,
                  child: Transform.scale(
                    // Scale down to scale of the smallest card in stack
                    scale: scaleAnimation.value,
                    child: child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// This widget is responsible for scaling up & sliding down
/// the background cards of the the card being dragged to give the
/// illusion that they replaced it
///
/// the animationController is passed to it from the parent widget
/// because the parent widget calls the forward() method on it
/// when it knows that the rotation main animation has been triggerred
class CoolSwiperCardWrapper extends StatefulWidget {
  final Widget child;
  final double initialScale;
  final double initialYOffset;
  final bool fire;
  final AnimationController animationController;

  const CoolSwiperCardWrapper({
    Key? key,
    required this.child,
    this.initialScale = 1,
    this.initialYOffset = 0,
    this.fire = false,
    required this.animationController,
  }) : super(key: key);

  @override
  State<CoolSwiperCardWrapper> createState() => _CoolSwiperCardWrapperState();
}

class _CoolSwiperCardWrapperState extends State<CoolSwiperCardWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> yOffsetAnimation;
  late final Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    animationController = widget.animationController;

    yOffsetAnimation = Tween<double>(
      begin: widget.initialYOffset,
      end: widget.initialYOffset - Constants.yOffset,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutBack,
      ),
    );

    scaleAnimation = Tween<double>(
      begin: widget.initialScale,
      end: widget.initialScale + Constants.scaleFraction,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (c, child) => Transform.translate(
        offset: Offset(0, -yOffsetAnimation.value),
        child: Transform.scale(
          scale: scaleAnimation.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

class CardContent extends StatelessWidget {
  final Color color;
  final List data;
  const CardContent({Key? key, required this.color, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Constants.cardHeight,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              //  crossAxisAlignment: CrossAxisAlignment.end,
//mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/stockimg/${data[0]}.jpg',
                    width: 160, height: 160, fit: BoxFit.contain),
                const SizedBox(height: 40),
                Center(
                    child: Text(data[1].toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 25))),
                /*
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 15,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 15,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                
              ],
            )
            */
              ],
            )),
      ),
    );
  }
}

Alignment getDragStartPositionAlignment(
  double xPosition,
  double yPosition,
  double width,
  double height,
) {
  if (xPosition > width / 2) {
    return yPosition > height / 2 ? Alignment.bottomRight : Alignment.topRight;
  } else {
    return yPosition > height / 2 ? Alignment.bottomLeft : Alignment.topLeft;
  }
}

class SwiperCard {
  final int order;
  final double scale;
  final double yOffset;
  final Widget child;
  final int totalCount;

  const SwiperCard({
    required this.order,
    required this.child,
    required this.totalCount,
  })  : scale = 1 - (order * Constants.scaleFraction),
        yOffset = order * Constants.yOffset;

  static List<SwiperCard> listFromWidgets(List<Widget> children) {
    return List.generate(
      children.length,
      (i) => SwiperCard(
        order: i,
        child: children[i],
        totalCount: children.length,
      ),
    ).reversed.toList();
  }
}

class Constants {
  static const double initAnimationOffset = 100;
  static const double cardHeight = 400;

  static const double dragStartEndAngle = 0.01;

  static const double rotationAnimationAngleDeg = 360;

  static const double scaleFraction = 0.05;
  static const double yOffset = 13;

  static const double throwSlideYDistance = 200;

  static const Duration backgroundCardsAnimationDuration =
      Duration(milliseconds: 300);
  static const Duration swipeAnimationDuration = Duration(milliseconds: 500);
}

class Data {
  static List<Color> colors = [
    Colors.red.shade300,
    Colors.yellow.shade200,
    Colors.blue.shade300,
    Colors.brown,
    Colors.blueGrey,
    Colors.purple,
    /*
    Colors.pink,
    Colors.orange,
    Colors.grey,
    Colors.lightBlue,
   
    Colors.red.shade300,
    Colors.yellow.shade200,
    Colors.blue.shade300,
    Colors.white,
    Colors.blue,
    Colors.red,
    Colors.pink,
    Colors.orange,
    Colors.grey,
    Colors.lightBlue,
    Colors.brown,
    Colors.blueGrey,
    Colors.purple*/
  ];
}
