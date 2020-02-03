# gsui
UI for Openfl with set of tools and utils.
Made in 2014/2015 for openfl legacy and now upgraded for openfl next and open sourced to make improvement easily.

# Use Case
Create your UI for a specific orientation (landscape or portrait) and the highest resolution you can, then GSUI will resize proportionnaly you UI to fit the screen for lower resolutions.
For now, if the screen ratio of the screen is different from the default one, you will have your ui letter-boxed.
There is no automatic repositioning of ui elements except for few components.

# component

- [x] group, vbox, hbox
- [x] render (group that uses item renderer)
- [x] img
- [x] grid9
- [x] text
- [x] simple Button
- [x] button
- [x] checkbox
- [x] radio
- [x] slider
- [x] progress bar
- [x] slot (place holder)
- [ ] scroll bar
 
# xml

## game state configuration

```
<data>
	<!-- 
	TAG is called by gui_create:TAG, gui_add:TAG or gui_remove:TAG
	attributes available:
		groups all groups that need to be on screen
		state is for the game state
		desaturate ensure that every child is not saturated
		saturate groups that must be saturated
	-->
	<start groups="start" desaturate="true" state="start" />
	<pause groups="pause" state="pause"/>
	<options groups="menuBackground,options" saturate="menuBackground" state="options"/>
</data>
```


## interface description

```
<!-- general and reusable values -->
<definitions>
	
	<text id="labelNormal" font="kenvector_future" size="28" color="0xb7b7b6" x="20" y="-2" />
	
	
	<slider id="slider" bg="grey_sliderHorizontal.png" button_def="sliderButton" label_def="labelSlider" y="center" />
	
	<simpleButton id="sliderButton" name="grey_sliderDown.png" hover="grey_sliderDown.png" y="center" />
	
	<progressBar id="life" img="grey_sliderHorizontal.png" cache="grey_sliderHorizontal.png" cover="grey_button06.png" width="168" />
	
</definitions>
<!-- sample of a ui -->
<group id="start">
	<img name="background.jpg"/>
	<img name="welcome.png" x="center" y="center" />
	<img name="logo.png" x="0" y="0" scale="0.3" />
	<group id="buttons" width="495" height="200" x="center" bottom="250" layout="v" gap="5">
		<button id="continue" x="center" width="190" height="40" click="gui_create:stats" state="continue" hitArea="true">
			<img name="grey_button01.png" y="center" state="up" />
			<img name="grey_button02.png" y="center" state="hover" />
			<text font="labelNormal" height="40" color="0x999694" hoverColor="0xc28b30" x="center" align="center" text="{$CONTINUE}"/>
		</button>
		<button id="stats" x="center"  width="190" height="40" click="gui_create:stats" hitArea="true">
			<img name="grey_button01.png" y="center" state="up" />
			<img name="grey_button02.png" y="center" state="hover" />
			<text font="labelNormal" height="40" color="0x999694" hoverColor="0xc28b30" x="center" align="center" text="{$STATS}"/>
		</button>
		<button id="options" x="center"  width="190" height="40" click="gui_create:options" hitArea="true">
			<img name="grey_button01.png" y="center" state="up" />
			<img name="grey_button02.png" y="center" state="hover" />
			<text font="labelNormal" height="40" color="0x999694" hoverColor="0xc28b30" x="center" align="center" text="{$OPTIONS}"/>
		</button>
	</group>
</group>
```

# Positioning on xml:
	
| position | xml attribute | value | warning |
| ------------- | ------------- | ------------- | ------------- |
| align center  | x, y  | center  | need to set parent width or height |
| align right minus width  | right  | width  | need to set parent width or height |
| align bottom minus height  | bottom  | height  | need to set parent width or height |

# Fonts:
	
Must be in fonts folder and have lowercase extension in ttf only.
	
	
# TODO
- [x] transitions
	- [x] actuate tween
	- [x] actuate transform
	- [x] actuate effects
	- [x] actuate apply
	- [x] on added
	- [x] on removed
	- [x] on hover
	- [x] on back to up
	- [x] other lib than actuate should be ok to used
- [ ] allow value 'auto' for width and height to make the parent width or height equal to children
- [ ] hot reload
- [ ] some responsiveness to avoid letterbox and better looking in mobile
- [ ] samples
- [ ] haxe 4 support
- [ ] documentation
- [ ] remove bindx2 dependency ?
- [ ] add macros to include classes from xml

# dependencies
- actuate
- bindx2
- openfl

