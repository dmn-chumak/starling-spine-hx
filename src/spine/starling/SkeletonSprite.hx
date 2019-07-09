package spine.starling;

import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import spine.attachments.Attachment;
import spine.attachments.ClippingAttachment;
import spine.attachments.MeshAttachment;
import spine.attachments.RegionAttachment;
import spine.Skeleton;
import spine.SkeletonData;
import spine.Slot;
import spine.support.graphics.Color;
import spine.support.graphics.TextureAtlas.AtlasRegion;
import spine.utils.SkeletonClipping;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.rendering.IndexData;
import starling.rendering.Painter;
import starling.rendering.VertexData;
import starling.textures.TextureSmoothing;
import starling.utils.MatrixUtil;
import Std;

class SkeletonSprite extends DisplayObject {
    private static var QUAD_INDICES:Array<Int> = [0, 1, 2, 2, 3, 0];
    private static var CLIPPER:SkeletonClipping = new SkeletonClipping();

    private static var BLEND_MODES:Array<String> = [BlendMode.NORMAL, BlendMode.ADD, BlendMode.MULTIPLY, BlendMode.SCREEN];
    private static var TEMP_VERTICIES:Array<Float> = [ 0, 0, 0, 0, 0, 0, 0, 0 ];
    private static var TEMP_POINT:Point = new Point();
    private static var TEMP_MATRIX:Matrix = new Matrix();

    public var skeleton(get, never):Skeleton;

    private var _twoColorTint:Bool;
    private var _skeleton:Skeleton;
    private var _smoothing:String;

    public function new(skeletonData:SkeletonData, twoColorTint:Bool = false) {
        super();

        _skeleton = new Skeleton(skeletonData);
        _skeleton.flipY = true;
        _skeleton.updateWorldTransform();

        _smoothing = TextureSmoothing.BILINEAR;
        _twoColorTint = twoColorTint;
    }

    override public function render(painter:Painter):Void {
        var clipper:SkeletonClipping = SkeletonSprite.CLIPPER;
        painter.state.alpha *= _skeleton.color.a;
        var originalBlendMode:String = painter.state.blendMode;
        var r:Float = _skeleton.color.r * 255;
        var g:Float = _skeleton.color.g * 255;
        var b:Float = _skeleton.color.b * 255;
        var drawOrder:Array<Slot> = _skeleton.drawOrder;
        var ii:Int, iii:Int;
        var attachmentColor:Color;
        var rgb:Int, a:Float;
        var dark:Int;
        var mesh:SkeletonMesh = null;
        var verticesLength:Int, verticesCount:Int, indicesLength:Int;
        var indexData:IndexData, indices:Array<Int>, vertexData:VertexData;
        var uvs:Array<Float>;

        for (i in 0...drawOrder.length) {
            var worldVertices:Array<Float> = TEMP_VERTICIES;
            var slot:Slot = drawOrder[i];

            if (Std.is(slot.attachment, RegionAttachment)) {
                var region:RegionAttachment = cast(slot.attachment, RegionAttachment);
                var rendererObject = region.getRegion().rendererObject;

                verticesLength = 4 * 2;
                verticesCount = verticesLength >> 1;

                while (worldVertices.length < verticesLength) {
                    worldVertices.push(0);
                }

                region.computeWorldVertices(slot.bone, worldVertices, 0, 2);
                indices = QUAD_INDICES;

                if (Std.is(rendererObject, SkeletonMesh)) {
                    mesh = cast(rendererObject, SkeletonMesh);
                } else {
                    if (Std.is(rendererObject, Image)) {
                        mesh = new SkeletonMesh(cast(rendererObject, Image).texture);
                    }

                    if (Std.is(rendererObject, AtlasRegion)) {
                        mesh = new SkeletonMesh(cast(cast(rendererObject, AtlasRegion).rendererObject, Image).texture);
                    }

                    region.getRegion().rendererObject = mesh;

                    if (_twoColorTint) mesh.setStyle(new TwoColorMeshStyle());

                    indexData = mesh.getIndexData();
                    for (ii in 0...indices.length) {
                        indexData.setIndex(ii, indices[ii]);
                    }

                    indexData.numIndices = indices.length;
                    indexData.trim();
                }

                indexData = mesh.getIndexData();
                attachmentColor = region.getColor();
                uvs = region.getUVs();
            } else if (Std.is(slot.attachment, MeshAttachment)) {
                var meshAttachment:MeshAttachment = cast(slot.attachment, MeshAttachment);
                var rendererObject = meshAttachment.getRegion().rendererObject;

                verticesLength = meshAttachment.worldVerticesLength;
                verticesCount = verticesLength >> 1;

                while (worldVertices.length < verticesLength) {
                    worldVertices.push(0);
                }

                meshAttachment.computeWorldVertices(slot, 0, meshAttachment.worldVerticesLength, worldVertices, 0, 2);

                indices = meshAttachment.getTriangles();
                if (Std.is(rendererObject, SkeletonMesh)) {
                    mesh = cast(rendererObject, SkeletonMesh);
                } else {
                    if (Std.is(rendererObject, Image)) {
                        mesh = new SkeletonMesh(cast(rendererObject, Image).texture);
                    }

                    if (Std.is(rendererObject, AtlasRegion)) {
                        mesh = new SkeletonMesh(cast(cast(rendererObject, AtlasRegion).rendererObject, Image).texture);
                    }

                    meshAttachment.getRegion().rendererObject = mesh;

                    if (_twoColorTint) mesh.setStyle(new TwoColorMeshStyle());

                    indexData = mesh.getIndexData();
                    indicesLength = meshAttachment.getTriangles().length;
                    for (ii in 0...indicesLength) {
                        indexData.setIndex(ii, indices[ii]);
                    }
                    indexData.numIndices = indicesLength;
                    indexData.trim();
                }


                indexData = mesh.getIndexData();
                attachmentColor = meshAttachment.getColor();
                uvs = meshAttachment.getUVs();
            } else if (Std.is(slot.attachment, ClippingAttachment)) {
                var clip:ClippingAttachment = cast(slot.attachment, ClippingAttachment);
                clipper.clipStart(slot, clip);
                continue;
            } else {
                continue;
            }

            a = slot.color.a * attachmentColor.a;
            if (a == 0) {
                clipper.clipEndWithSlot(slot);
                continue;
            }
            rgb = starling.utils.Color.rgb(Std.int(r * slot.color.r * attachmentColor.r), Std.int(g * slot.color.g * attachmentColor.g), Std.int(b * slot.color.b * attachmentColor.b));
            if (slot.darkColor == null) dark = starling.utils.Color.rgb(0, 0, 0);
            else dark = starling.utils.Color.rgb(Std.int(slot.darkColor.r * 255), Std.int(slot.darkColor.g * 255), Std.int(slot.darkColor.b * 255));

            if (clipper.isClipping()) {
                clipper.clipTriangles(worldVertices, worldVertices.length, indices, indices.length, uvs, rgb, dark, _twoColorTint);

                // Need to create a new mesh here, see https://github.com/EsotericSoftware/spine-runtimes/issues/1125
                mesh = new SkeletonMesh(mesh.texture);
                if (_twoColorTint) mesh.setStyle(new TwoColorMeshStyle());
                indexData = mesh.getIndexData();

                verticesCount = clipper.getClippedVertices().length >> 1;
                worldVertices = clipper.getClippedVertices();
                uvs = clipper.getClippedVertices();

                indices = clipper.getClippedTriangles();
                indicesLength = indices.length;
                indexData.numIndices = indicesLength;
                indexData.trim();
                for (ii in 0...indicesLength) {
                    indexData.setIndex(ii, indices[ii]);
                }
            }

            vertexData = mesh.getVertexData();
            vertexData.numVertices = verticesCount;

            vertexData.colorize("color", rgb, a);
            if (_twoColorTint) vertexData.colorize("color2", dark);

            iii = 0;

            for (ii in 0...verticesCount) {
                mesh.setVertexPosition(ii, worldVertices[iii], worldVertices[iii + 1]);
                mesh.setTexCoords(ii, uvs[iii], uvs[iii + 1]);
                iii += 2;
            }

            if (indexData.numIndices > 0 && vertexData.numVertices > 0) {
                painter.state.blendMode = BLEND_MODES[slot.data.blendMode];
                painter.batchMesh(mesh);
            }

            clipper.clipEndWithSlot(slot);
        }
        painter.state.blendMode = originalBlendMode;
        clipper.clipEnd();
    }

    override public function hitTest(localPoint:Point):DisplayObject {
        if (!this.visible || !this.touchable) return null;

        var minX:Float = 100000, minY:Float = 100000;
        var maxX:Float = -100000, maxY:Float = -100000;
        var slots:Array<Slot> = _skeleton.slots;
        var worldVertices:Array<Float> = TEMP_VERTICIES;
        var empty:Bool = true;

        for (i in 0...slots.length) {
            var slot:Slot = slots[i];
            var attachment:Attachment = slot.attachment;
            if (attachment == null) {
                continue;
            }

            var verticesLength:Int;


            if (Std.is(attachment, RegionAttachment)) {
                var region:RegionAttachment = cast(slot.attachment, RegionAttachment);
                verticesLength = 8;
                region.computeWorldVertices(slot.bone, worldVertices, 0, 2);
            } else if (Std.is(attachment, MeshAttachment)) {
                var mesh:MeshAttachment = cast(attachment, MeshAttachment);
                verticesLength = mesh.worldVerticesLength;

                while (worldVertices.length < verticesLength) {
                    worldVertices.push(0);
                }

                mesh.computeWorldVertices(slot, 0, verticesLength, worldVertices, 0, 2);
            } else
                continue;

            if (verticesLength != 0)
                empty = false;

            var iii = 0;

            for (ii in 0...verticesLength) {
                var x:Float = worldVertices[iii], y:Float = worldVertices[iii + 1];
                minX = minX < x ? minX : x;
                minY = minY < y ? minY : y;
                maxX = maxX > x ? maxX : x;
                maxY = maxY > y ? maxY : y;
                iii += 2;
            }
        }

        if (empty) {
            return null;
        }

        var temp:Float;
        if (maxX < minX) {
            temp = maxX;
            maxX = minX;
            minX = temp;
        }
        if (maxY < minY) {
            temp = maxY;
            maxY = minY;
            minY = temp;
        }

        if (localPoint.x >= minX && localPoint.x < maxX && localPoint.y >= minY && localPoint.y < maxY)
            return this;

        return null;
    }

    override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle {
        if (out == null) {
            out = new Rectangle();
        }

        if (targetSpace == this) {
            out.setTo(0, 0, 0, 0);
        } else if (targetSpace == parent) {
            out.setTo(x, y, 0, 0);
        } else {
            getTransformationMatrix(targetSpace, TEMP_MATRIX);
            MatrixUtil.transformCoords(TEMP_MATRIX, 0, 0, TEMP_POINT);
            out.setTo(TEMP_POINT.x, TEMP_POINT.y, 0, 0);
        }

        return out;
    }

    private function get_skeleton():Skeleton {
        return _skeleton;
    }
}
