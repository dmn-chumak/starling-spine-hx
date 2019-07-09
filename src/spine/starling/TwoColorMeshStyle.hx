package spine.starling;

import starling.rendering.MeshEffect;
import starling.rendering.VertexDataFormat;
import starling.styles.MeshStyle;

class TwoColorMeshStyle extends MeshStyle {
    public static var VERTEX_FORMAT:VertexDataFormat = MeshStyle.VERTEX_FORMAT.extend("color2:bytes4");

    override private function get_vertexFormat():VertexDataFormat {
        return VERTEX_FORMAT;
    }

    override public function createEffect():MeshEffect {
        return new TwoColorEffect();
    }
}
