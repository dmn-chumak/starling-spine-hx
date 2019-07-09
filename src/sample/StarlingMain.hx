package sample;

import openfl.utils.Assets;
import spine.attachments.AtlasAttachmentLoader;
import spine.attachments.AttachmentLoader;
import spine.SkeletonJson;
import spine.starling.SkeletonAnimation;
import spine.starling.StarlingAssetsFile;
import spine.starling.StarlingAtlasAttachmentLoader;
import spine.starling.StarlingTextureLoader;
import starling.core.Starling;
import starling.display.Sprite;
import starling.textures.Texture;

class StarlingMain extends Sprite {
    public function new() {
        super();

        var skeletonFile = new StarlingAssetsFile("goblin/goblins-pro.json");
        var loaders = [ createFromStarlingAtlas(), createFromSpineAtlas() ];

        for (index in 0...loaders.length) {
            var skeletonJson = new SkeletonJson(loaders[index]);
            var skeletonData = skeletonJson.readSkeletonData(skeletonFile);
            var skeleton = new SkeletonAnimation(skeletonData);

            skeleton.y = 100 + (Starling.current.stage.stageHeight - 200) * Math.random();
            skeleton.x = 100 + (Starling.current.stage.stageWidth - 200) * Math.random();
            skeleton.skeleton.setSkinByName("goblin");
            skeleton.skeleton.setSlotsToSetupPose();
            skeleton.state.setAnimationByName(0, "walk", true);

            Starling.current.juggler.add(skeleton);
            addChild(skeleton);
        }
    }

    private function createFromStarlingAtlas():AttachmentLoader {
        var textureAtlas = new spine.support.graphics.TextureAtlas(
            Assets.getText("goblin/goblins.atlas"),
            new StarlingTextureLoader(
                Texture.fromBitmapData(Assets.getBitmapData("goblin/goblins.png"))
            )
        );

        return new AtlasAttachmentLoader(textureAtlas);
    }

    private function createFromSpineAtlas():AttachmentLoader {
        var textureAtlas = new starling.textures.TextureAtlas(
            Texture.fromBitmapData(Assets.getBitmapData("goblin/goblins-mesh-starling.png")),
            Assets.getText("goblin/goblins-mesh-starling.xml")
        );

        return new StarlingAtlasAttachmentLoader(textureAtlas);
    }
}
