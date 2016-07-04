import java.util.Iterator;
import org.nlogo.agent.World;
import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.DefaultReporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.api.LogoListBuilder;
import org.nlogo.api.Syntax;

/**
 * Reports a list of all breed names declared in the Netlogo model that the 
 * primitive is used in as lowercase "String" objects.
 * 
 * @author Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
 */
public class GetListOfAllBreedNames extends DefaultReporter {
  
  @Override
  public Syntax getSyntax(){
    return Syntax.reporterSyntax(new int[]{}, Syntax.ListType());
  }
  
  @Override
  public Object report(Argument[] args, Context context) throws ExtensionException, LogoException {
    LogoListBuilder breedNames = new LogoListBuilder();
    World world = (World) context.getAgent().world();
    Iterator<String> breeds = world.getBreeds().keySet().iterator();
    while(breeds.hasNext()){
      breedNames.add(breeds.next().toLowerCase());
      
    }
    return breedNames.toLogoList();
  }
  
}
