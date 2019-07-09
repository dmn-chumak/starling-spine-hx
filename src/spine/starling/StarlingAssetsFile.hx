package spine.starling;

import openfl.utils.Assets;
import spine.support.files.FileHandle;

class StarlingAssetsFile implements FileHandle {
    public var path:String;

    public function new(id:String) {
        path = id;
    }

    public function getContent():String {
        return Assets.getText(path);
    }
}
