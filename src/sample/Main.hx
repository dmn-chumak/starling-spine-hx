package sample;

import openfl.display.Sprite;
import starling.core.Starling;
import starling.utils.Align;

class Main extends Sprite {
    public function new() {
        super();

        var starling = new Starling(StarlingMain, stage);

        starling.showStatsAt(Align.LEFT, Align.BOTTOM);
        starling.enableErrorChecking = false;
        starling.supportHighResolutions = true;
        starling.antiAliasing = 0;

        starling.start();
    }
}
