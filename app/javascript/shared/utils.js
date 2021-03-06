import Rails from '@rails/ujs';
import $ from 'jquery';
import debounce from 'debounce';

export { debounce };
export const { fire, ajax } = Rails;

export function show(el) {
  el && el.classList.remove('hidden');
}

export function hide(el) {
  el && el.classList.add('hidden');
}

export function toggle(el) {
  el && el.classList.toggle('hidden');
}

export function enable(el) {
  el && (el.disabled = false);
}

export function disable(el) {
  el && (el.disabled = true);
}

export function hasClass(el, cssClass) {
  return el && el.classList.contains(cssClass);
}

export function addClass(el, cssClass) {
  el && el.classList.add(cssClass);
}

export function removeClass(el, cssClass) {
  el && el.classList.remove(cssClass);
}

export function delegate(eventNames, selector, callback) {
  eventNames
    .split(' ')
    .forEach(eventName =>
      Rails.delegate(document, selector, eventName, callback)
    );
}

export function getJSON(url, data, method = 'get') {
  incrementActiveRequestsCount();
  data = method !== 'get' ? JSON.stringify(data) : data;
  return Promise.resolve(
    $.ajax({
      method,
      url,
      data,
      contentType: 'application/json',
      dataType: 'json'
    })
  ).finally(decrementActiveRequestsCount);
}

export function scrollTo(container, scrollTo) {
  container.scrollTop =
    offset(scrollTo).top - offset(container).top + container.scrollTop;
}

export function scrollToBottom(container) {
  container.scrollTop = container.scrollHeight;
}

export function on(selector, eventName, fn) {
  [...document.querySelectorAll(selector)].forEach(element =>
    element.addEventListener(eventName, event => fn(event, event.detail))
  );
}

export function to(promise) {
  return promise.then(result => [result]).catch(error => [null, error]);
}

function offset(element) {
  const rect = element.getBoundingClientRect();
  return {
    top: rect.top + document.body.scrollTop,
    left: rect.left + document.body.scrollLeft
  };
}

// Takes a promise, and return a promise that times out after the given delay.
export function timeoutable(promise, timeoutDelay) {
  let timeoutPromise = new Promise((resolve, reject) => {
    setTimeout(() => {
      reject(new Error(`Promise timed out after ${timeoutDelay}ms`));
    }, timeoutDelay);
  });
  return Promise.race([promise, timeoutPromise]);
}

const DATA_ACTIVE_REQUESTS_COUNT = 'data-active-requests-count';

function incrementActiveRequestsCount() {
  const count = document.body.getAttribute(DATA_ACTIVE_REQUESTS_COUNT) || '0';
  document.body.setAttribute(DATA_ACTIVE_REQUESTS_COUNT, parseInt(count) + 1);
}

function decrementActiveRequestsCount() {
  const count = document.body.getAttribute(DATA_ACTIVE_REQUESTS_COUNT) || '0';
  document.body.setAttribute(DATA_ACTIVE_REQUESTS_COUNT, parseInt(count) - 1);
}
