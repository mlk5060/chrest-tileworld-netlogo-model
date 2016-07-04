import java.util.logging.Level;
import java.util.logging.Logger;
import org.nlogo.api.AgentException;
import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.DefaultReporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.api.Syntax;
import org.nlogo.agent.World;

/**
 * Returns the angle that must be turned to to face from an x/y-coordinate in
 * the Netlogo model to another x/y-coordinate in the Netlogo model.
 * 
 * Five parameters must be passed when the Netlogo extension primitive that 
 * invokes this class is used in a Netlogo model:
 * 
 * Param #      Data Type       Description
 * -------      ---------       -----------
 * 1            Number          The xcor of the origin point.
 * 2            Number          The ycor of the origin point.
 * 3            Number          The xcor of the target point.
 * 4            Number          The ycor of the target point.
 * 5            Boolean         Whether the Netlogo model wraps or not.
 * 
 * @author Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
 */
public class Towards extends DefaultReporter {
  
  @Override
  public Syntax getSyntax() {
    return Syntax.reporterSyntax(new int[]{Syntax.NumberType(), Syntax.NumberType(), Syntax.NumberType(), Syntax.NumberType(), Syntax.BooleanType()}, Syntax.NumberType());
  }
  
  @Override
  public Object report(Argument[] args, Context context) throws ExtensionException, LogoException {
    Double fromX = args[0].getDoubleValue();
    Double fromY = args[1].getDoubleValue();
    Double toX = args[2].getDoubleValue();
    Double toY = args[3].getDoubleValue();
    boolean wrap = args[4].getBooleanValue();
    Double result = null;
    
    World world = (org.nlogo.agent.World)context.getAgent().world();
    try {
      result = world.protractor().towards(fromX, fromY, toX, toY, wrap);
    } catch (AgentException ex) {
      Logger.getLogger(Towards.class.getName()).log(Level.SEVERE, "", ex);
    }
    
    return result;
  }
  
}
