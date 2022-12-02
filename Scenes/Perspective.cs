using Godot;
using System;
using System.Collections.Generic;

public class Perspective : Node2D
{

    float globTime = 0f;

    Vector3 globPos = Vector3.Zero;
    Vector3 globRot = Vector3.Zero;
    Vector3 surface = new Vector3(0,0,1);

    Basis CamBasis;

    List<Vector3> points = new List<Vector3>();
    List<Vector3> pointsInitial = new List<Vector3>();

	public override void _Ready()
	{
		for (int x = 0; x < 10; x++) {

            for (int y = 0; y < 10; y++) {

                for (int z = 0; z < 10; z++) {

                    points.Add(new Vector3(x,y,z));
                    pointsInitial.Add(new Vector3(x,y,z));

                }

            }

        }
	}

	public override void _Process(float delta)
	{
		
        // for (int i = 0; i < points.Count; i++) {

        //     points[i] = pointsInitial[i] + 
        //         Vector3.Up * Mathf.Sin(globTime + i) * 0.1f +
        //         Vector3.Right * Mathf.Sin(globTime + i + 0.2f) * 0.1f;

        // }

        UpdateCamBasis();
        Basis invBasis = CamBasis.Inverse();
        globTime += delta;

        if (!Input.IsActionPressed("p_modifySurface")) {

            globPos += invBasis.x * Input.GetAxis("p_left","p_right") * delta;
            globPos += invBasis.y * Input.GetAxis("p_above","p_below") * delta;
            globPos += invBasis.z * Input.GetAxis("p_down","p_up") * delta;

        } else {

            surface += new Vector3(
                Input.GetAxis("p_left","p_right"),
                Input.GetAxis("p_above","p_below"),
                Input.GetAxis("p_down","p_up")
            ) * delta;

        }
        
        Update();

	}

    public override void _UnhandledInput(InputEvent @event)
	{
		InputEventMouseMotion mEvent = @event as InputEventMouseMotion;
        InputEventKey kEvent = @event as InputEventKey;

        if (kEvent != null) {

            if (kEvent.Scancode == (uint)KeyList.Key0)
                GD.Print(CamBasis);
            
            if (kEvent.Scancode == (uint)KeyList.Escape && kEvent.Pressed) {

                if (Input.MouseMode == Input.MouseModeEnum.Visible) 
                    Input.MouseMode = Input.MouseModeEnum.Captured;
                else Input.MouseMode = Input.MouseModeEnum.Visible;

            }

        }

        if (mEvent != null) {

            globRot.y += mEvent.Relative.x * 0.002f;
            globRot.x -= mEvent.Relative.y * 0.002f;

        }
	}

	public override void _Draw()
	{
		foreach (Vector3 p in points) {

            Vector3 pos = CamBasis.Xform(p - globPos);
            
            if (pos.z < 0) continue;
            if (pos.z > 5) continue;

            float dRatio = surface.z/pos.z;
            Vector2 proj = new Vector2(
                pos.x*dRatio+surface.x,
                pos.y*dRatio+surface.y
            ) * 128;

            DrawCircle(proj, 2*dRatio, Colors.White);

        }

	}

    void UpdateCamBasis() {

        Basis camTX = new Basis(
            new Vector3(1,0,0),
            new Vector3(0,Mathf.Cos(globRot.x),-Mathf.Sin(globRot.x)),
            new Vector3(0,Mathf.Sin(globRot.x),Mathf.Cos(globRot.x))
        );
        Basis camTY = new Basis(
            new Vector3(Mathf.Cos(globRot.y),0,Mathf.Sin(globRot.y)),
            new Vector3(0,1,0),
            new Vector3(-Mathf.Sin(globRot.y),0,Mathf.Cos(globRot.y))
        );
        Basis camTZ = new Basis(
            new Vector3(Mathf.Cos(globRot.z),Mathf.Sin(globRot.z),0),
            new Vector3(-Mathf.Sin(globRot.z),Mathf.Cos(globRot.z),0),
            new Vector3(0,0,1)
        );
        
        CamBasis = camTX*camTY*camTZ;

    }
    

}
