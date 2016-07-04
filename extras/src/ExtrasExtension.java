import org.nlogo.api.DefaultClassManager;
import org.nlogo.api.PrimitiveManager;

/**
 * Primitive manager for "extras" Netlogo extension.
 * 
 * @author Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
 */
public class ExtrasExtension extends DefaultClassManager {

  @Override
  public void load(PrimitiveManager primitiveManager) {
    primitiveManager.addPrimitive("get-list-of-all-breed-names", new GetListOfAllBreedNames());
    primitiveManager.addPrimitive("distance", new Distance());
    primitiveManager.addPrimitive("towards", new Towards());
  }
}
