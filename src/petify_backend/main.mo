import Text "mo:base/Text";
import Time "mo:base/Time";
import Hash "mo:base/Hash";
import Map "mo:base/HashMap";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import Option "mo:base/Option";
import Bool "mo:base/Bool";

actor Petify {
  type Contact = {
    fullname : Text;
    address : Text;
    phone : Nat;
  };

  type Pet = {
    petType : Text;
    kind : Text;
    sex : Text;
    color : Text;
    distinctFeature : Text;
    name : Text;
  };

  type Time = Int; // represented as nanoseconds since 01-01-1970

  type Announcement = {
    pet : Pet;
    contact : Contact;
    lostDate : Time;
    foundDate : Time;
  };

  private func natHash(n : Nat) : Hash.Hash {
    Text.hash(Nat.toText(n));
  };

  var lostPets = Map.HashMap<Nat, Announcement>(1, Nat.equal, natHash);
  var foundPets = Map.HashMap<Nat, Announcement>(1, Nat.equal, natHash);
  var nextId : Nat = 1;

  private func getLostPets() : async [Announcement] {
    Iter.toArray(lostPets.vals());
  };

  private func getFoundPets() : async [Announcement] {
    Iter.toArray(foundPets.vals());
  };

  public func newLost(
    pet : Pet,
    contact : Contact,
  ) : async Text {
    let id = nextId;
    lostPets.put(
      id,
      {
        pet = {
          petType = pet.petType;
          kind = pet.kind;
          sex = pet.sex;
          color = pet.color;
          distinctFeature = pet.distinctFeature;
          name = pet.name;
        };
        contact = {
          fullname = contact.fullname;
          address = contact.address;
          phone = contact.phone;
        };
        lostDate = Time.now();
        foundDate = -1;
      },
    );
    nextId += 1;
    "Successfully added with ID " # Nat.toText(id) # ".";
  };

  public func foundThePet(id : ?Nat) : async (Text) {
    let maybeNullId : ?Nat = id;
    let isNull : Bool = Option.isNull(id);
    if (not isNull) {
      let id : Nat = Option.get(maybeNullId, 0);
      // get the found pet by id
      ignore do ? {
        let found = lostPets.get(id)!;
        // add the found pet to the found pets list
        foundPets.put(
          id,
          {
            pet = {
              petType = found.pet.petType;
              kind = found.pet.kind;
              sex = found.pet.sex;
              color = found.pet.color;
              distinctFeature = found.pet.distinctFeature;
              name = found.pet.name;
            };
            contact = {
              fullname = found.contact.fullname;
              address = found.contact.address;
              phone = found.contact.phone;
            };
            lostDate = found.lostDate;
            foundDate = Time.now();
          },
        );
      };
      // remove from lost pets list
      lostPets.delete(id);
      "Successfully added item with ID " # Nat.toText(id) # ".";
    } else {
      "Please enter the ID.";
    };
  };

  public query func showLostPets() : async Text {
    var output : Text = "\n______LOST PETS______";
    for (ann : Announcement in lostPets.vals()) {
      output #= "\nLost Date (Timestamp) : " # Int.toText(ann.lostDate);
      output #= "\nName : " # ann.pet.name;
      output #= "\nKind : " # ann.pet.kind;
      output #= "\nSex : " # ann.pet.sex;
      output #= "\nColor : " # ann.pet.color;
      output #= "\nDistinct Feature : " # ann.pet.distinctFeature;
      output #= "\nContact Full Name : " # ann.contact.fullname;
      output #= "\nContact Address : " # ann.contact.address;
      output #= "\nContact Phone : " # Nat.toText(ann.contact.phone);
      output #= "\n---------------------------------";
    };
    output # "\n";
  };

  public query func showFoundPets() : async Text {
    var output : Text = "\n______FOUND PETS______";
    for (ann : Announcement in foundPets.vals()) {
      output #= "\nFound Date (Timestamp) : " # Int.toText(ann.foundDate);
      output #= "\nLost Date (Timestamp) : " # Int.toText(ann.lostDate);
      output #= "\nName : " # ann.pet.name;
      output #= "\nKind : " # ann.pet.kind;
      output #= "\nSex : " # ann.pet.sex;
      output #= "\nColor : " # ann.pet.color;
      output #= "\nDistinct Feature : " # ann.pet.distinctFeature;
      output #= "\nContact Full Name : " # ann.contact.fullname;
      output #= "\nContact Address : " # ann.contact.address;
      output #= "\nContact Phone : " # Nat.toText(ann.contact.phone);
      output #= "\n---------------------------------";
    };
    output # "\n";
  };
};
