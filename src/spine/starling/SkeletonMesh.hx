package spine.starling;

import starling.display.Mesh;
import starling.rendering.IndexData;
import starling.rendering.VertexData;
import starling.textures.Texture;

class SkeletonMesh extends Mesh {
    public function new(texture:Texture) {
        super(new VertexData(), new IndexData(), null);

        style.texture = texture;
    }

    public function getVertexData():VertexData {
        return vertexData;
    }

    public function getIndexData():IndexData {
        return indexData;
    }
}
