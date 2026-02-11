using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;

public class ButtonPop : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerExitHandler
{
    public float pressedScale = 1.08f;
    public float downDuration = 0.06f;
    public float upDuration = 0.08f;

    private RectTransform rt;
    private Vector3 normalScale;
    private Coroutine anim;

    void Awake()
    {
        rt = GetComponent<RectTransform>();
        normalScale = rt.localScale;
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        StartAnim(normalScale * pressedScale, downDuration);
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        StartAnim(normalScale, upDuration);
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        StartAnim(normalScale, upDuration);
    }

    private void StartAnim(Vector3 target, float duration)
    {
        if (anim != null) StopCoroutine(anim);
        anim = StartCoroutine(ScaleTo(target, duration));
    }

    private IEnumerator ScaleTo(Vector3 target, float duration)
    {
        var start = rt.localScale;
        float t = 0f;

        while (t < duration)
        {
            t += Time.unscaledDeltaTime;
            rt.localScale = Vector3.Lerp(start, target, Mathf.Clamp01(t / duration));
            yield return null;
        }

        rt.localScale = target;
        anim = null;
    }
}
