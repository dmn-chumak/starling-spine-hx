package spine.starling;

import openfl.display3D.Context3D;
import openfl.display3D.Context3DProgramType;
import openfl.Vector;
import starling.rendering.FilterEffect;
import starling.rendering.MeshEffect;
import starling.rendering.Program;
import starling.rendering.VertexDataFormat;

class TwoColorEffect extends MeshEffect {
    public static var VERTEX_FORMAT:VertexDataFormat = TwoColorMeshStyle.VERTEX_FORMAT;
    public static var VECTOR_ONES:Vector<Float> = new Vector<Float>([1, 1, 1, 1]);

    override private function createProgram():Program {
        // v0 -> tex coords
        // v1 -> color plus alpha
        // v2 -> dark color

        var vertexShader:String = [
            "m44 op, va0, vc0",                         // 4x4 matrix transform to output clip-space
            "mov v0, va1     ",                         // pass texture coordinates to fragment program
            "mul v1, va2, vc4",                         // multiply alpha (vc4) with color (va2), pass to fp
            "mov v2, va3     "                          // pass dark color to fp
        ].join("\n");

        // fc0 -> (1, 1, 1, 1)

        var fragmentShader:String = [
            FilterEffect.tex("ft0", "v0", 0, texture),  // ft0 = texture2d(texCoords)
            "mul ft1, ft0, v1",                         // ft1 = texColor * light
            "sub ft3.xyz, ft0.www, fc0.xyz",            // ft3 = texColor.a - 1
            "sub ft2.xyz, fc0.xyz, ft0.xyz",            // ft2.xyz = (1 - texColor.rgb)
            "add ft2.xyz, ft2.xyz, ft3.xyz",            // ft2.xyz = ((texColor.a - 1.0) + 1.0 - texColor.rgb)
            "mul ft2.xyz, ft2.xyz, v2.xyz",             // ft2.xyz = ((texColor.a - 1.0) + 1.0 - texColor.rgb) * dark.rgb
            "add ft2.xyz, ft2.xyz, ft1.xyz",            // ft2.xyz = ((texColor.a - 1.0) + 1.0 - texColor.rgb) * dark.rgb + texColor.rgb * light.rgb
            "mov ft2.w, ft1.w",                         // ft2.w = alpha
            "mov oc, ft2"
        ].join("\n");

        return Program.fromSource(
            vertexShader,
            fragmentShader
        );
    }

    override private function get_vertexFormat():VertexDataFormat {
        return VERTEX_FORMAT;
    }

    override private function beforeDraw(context:Context3D):Void {
        super.beforeDraw(context);

        vertexFormat.setVertexBufferAt(3, vertexBuffer, "color2");
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, VECTOR_ONES);
    }

    override private function afterDraw(context:Context3D):Void {
        context.setVertexBufferAt(3, null);

        super.afterDraw(context);
    }
}
