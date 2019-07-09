package spine.starling;

import spine.AnimationState;
import spine.AnimationStateData;
import spine.SkeletonData;
import starling.animation.IAnimatable;

class SkeletonAnimation extends SkeletonSprite implements IAnimatable {
    public var state:AnimationState;
    public var speed:Float;

    public function new(skeletonData:SkeletonData, stateData:AnimationStateData = null) {
        super(skeletonData);

        if (stateData == null) {
            stateData = new AnimationStateData(skeletonData);
        }

        state = new AnimationState(stateData);
        speed = 1.0;
    }

    public function advanceTime(time:Float):Void {
        var actualTime = time * speed;

        _skeleton.update(actualTime);
        state.update(actualTime);
        state.apply(_skeleton);
        _skeleton.updateWorldTransform();

        setRequiresRedraw();
    }
}
