package spine.starling;

import flash.geom.Rectangle;
import spine.attachments.AttachmentLoader;
import spine.attachments.BoundingBoxAttachment;
import spine.attachments.ClippingAttachment;
import spine.attachments.MeshAttachment;
import spine.attachments.PathAttachment;
import spine.attachments.PointAttachment;
import spine.attachments.RegionAttachment;
import spine.Skin;
import spine.support.error.Error;
import spine.support.graphics.TextureAtlas.AtlasRegion;
import starling.display.Image;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class StarlingAtlasAttachmentLoader implements AttachmentLoader {
    private var _textureAtlas:TextureAtlas;

    public function new(textureAtlas:TextureAtlas) {
        _textureAtlas = textureAtlas;
    }

    public function newRegionAttachment(skin:Skin, name:String, path:String):RegionAttachment {
        var texture:SubTexture = cast _textureAtlas.getTexture(path);

        if (texture == null) {
            throw new Error("Region not found in Starling atlas: " + path + " (region attachment: " + name + ")");
        }

        var attachment = new RegionAttachment(name);
        var textureFrame = texture.frame;
        var region = new AtlasRegion();

        if (textureFrame == null) {
            textureFrame = new Rectangle(0, 0, texture.width, texture.height);
        }

        region.rendererObject = new Image(Texture.fromTexture(texture));
        region.height = Std.int(texture.height);
        region.width = Std.int(texture.width);
        region.originalHeight = Std.int(textureFrame.height);
        region.originalWidth = Std.int(textureFrame.width);
        region.offsetX = -textureFrame.x;
        region.offsetY = -textureFrame.y;
        region.rotate = texture.rotated;
        region.name = name;

        if (texture.rotated) {
            var temp = region.originalHeight;
            region.originalHeight = region.originalWidth;
            region.originalWidth = temp;

            temp = region.height;
            region.height = region.width;
            region.width = temp;

            region.u = 1;
            region.v = 0;
            region.u2 = 0;
            region.v2 = 1;
        } else {
            region.u = 0;
            region.v = 0;
            region.u2 = 1;
            region.v2 = 1;
        }

        attachment.setRegion(region);

        return attachment;
    }

    public function newMeshAttachment(skin:Skin, name:String, path:String):MeshAttachment {
        var texture:SubTexture = cast _textureAtlas.getTexture(path);

        if (texture == null) {
            throw new Error("Region not found in Starling atlas: " + path + " (mesh attachment: " + name + ")");
        }

        var attachment = new MeshAttachment(name);
        var textureRegion = texture.region;
        var textureRoot = texture.root;
        var textureFrame = texture.frame;
        var region = new AtlasRegion();

        if (textureFrame == null) {
            textureFrame = new Rectangle(0, 0, texture.width, texture.height);
        }

        region.rendererObject = new Image(textureRoot);
        region.height = Std.int(texture.height);
        region.width = Std.int(texture.width);
        region.originalHeight = Std.int(textureFrame.height);
        region.originalWidth = Std.int(textureFrame.width);
        region.offsetX = -textureFrame.x;
        region.offsetY = -textureFrame.y;
        region.rotate = texture.rotated;
        region.name = name;

        if (texture.rotated) {
            var temp = region.originalHeight;
            region.originalHeight = region.originalWidth;
            region.originalWidth = temp;

            temp = region.height;
            region.height = region.width;
            region.width = temp;

            region.u2 = textureRegion.x / textureRoot.width;
            region.v2 = textureRegion.y / textureRoot.height;
            region.u = (textureRegion.x + texture.height) / textureRoot.width;
            region.v = (textureRegion.y + texture.width) / textureRoot.height;
        } else {
            region.u = textureRegion.x / textureRoot.width;
            region.v = textureRegion.y / textureRoot.height;
            region.u2 = (textureRegion.x + texture.width) / textureRoot.width;
            region.v2 = (textureRegion.y + texture.height) / textureRoot.height;
        }

        attachment.setRegion(region);

        return attachment;
    }

    public function newBoundingBoxAttachment(skin:Skin, name:String):BoundingBoxAttachment {
        return new BoundingBoxAttachment(name);
    }

    public function newClippingAttachment(skin:Skin, name:String):ClippingAttachment {
        return new ClippingAttachment(name);
    }

    public function newPathAttachment(skin:Skin, name:String):PathAttachment {
        return new PathAttachment(name);
    }

    public function newPointAttachment(skin:Skin, name:String):PointAttachment {
        return new PointAttachment(name);
    }
}
