using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class MixerStation : GenericObject, IWorkstation
{
    private bool _isOccupied = false;
    [SerializeField] private List<Ingredient> _requiredIngredients;
    private List<Ingredient> _currentIngredients = new List<Ingredient>();
    [SerializeField] private Ingredient mixingOutput;
    [SerializeField] private Transform outputPoint;
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public void ProcessFood(Ingredient ingredient)
    {
        if (CheckIngredientList(ingredient) && ingredient.GetCookingType() == CookingType.MIXER)
        {
            _currentIngredients.Add(ingredient);
            ingredient.gameObject.SetActive(false);
            
            if(_currentIngredients.Count == _requiredIngredients.Count)
                StartCoroutine(DoMixing(mixingOutput));
        }
        
    }

    public bool CheckIngredientList(Ingredient ingredient)
    {
        if (_requiredIngredients.Contains(ingredient) && !_currentIngredients.Contains(ingredient))
            return true;
        return false;
    }

    IEnumerator DoMixing(Ingredient ingredient)
    {
        _isOccupied = true;
        
        //feedback de que esta cortando
        yield return new WaitForSeconds(ingredient.GetDuration());
        
        GameObject finalOutput = Instantiate(ingredient.GetOutput());
        ingredient.gameObject.SetActive(false);
        
        finalOutput.transform.position = outputPoint.position;
        _isOccupied = false;
        
        yield return null;
    }
}
