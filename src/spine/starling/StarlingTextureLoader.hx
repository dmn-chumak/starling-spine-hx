package spine.starling;

import spine.support.graphics.TextureAtlas.AtlasPage;
import spine.support.graphics.TextureAtlas.AtlasRegion;
import spine.support.graphics.TextureLoader;
import starling.display.Image;
import starling.textures.Texture;

class StarlingTextureLoader implements TextureLoader {
    private var _texture:Texture;

    public function new(texture:Texture) {
        _texture = texture;
    }

    public function loadPage(page:AtlasPage, path:String):Void {
        page.rendererObject = _texture;
        page.height = Std.int(_texture.height);
        page.width = Std.int(_texture.width);
    }

    public function loadRegion(region:AtlasRegion):Void {
        var image:Image = new Image(cast region.page.rendererObject);

        if (region.rotate) {
            image.setTexCoords(0, region.u, region.v2);
            image.setTexCoords(1, region.u, region.v);
            image.setTexCoords(2, region.u2, region.v2);
            image.setTexCoords(3, region.u2, region.v);
        } else {
            image.setTexCoords(0, region.u, region.v);
            image.setTexCoords(1, region.u2, region.v);
            image.setTexCoords(2, region.u, region.v2);
            image.setTexCoords(3, region.u2, region.v2);
        }

        region.rendererObject = image;
    }

    public function unloadPage(page:AtlasPage):Void {
        cast(page, Texture).dispose();
    }
}
