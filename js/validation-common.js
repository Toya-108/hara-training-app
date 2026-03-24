(function (window) {
    'use strict';

    function getMessageElement(field) {
        return document.querySelector('[data-for="' + field.id + '"]');
    }

    function showFieldError(field, message) {
        var messageElement = getMessageElement(field);

        field.classList.add('is-error');

        if (messageElement) {
            messageElement.textContent = message;
            messageElement.classList.add('is-visible');
        }
    }

    function clearFieldError(field) {
        var messageElement = getMessageElement(field);

        field.classList.remove('is-error');

        if (messageElement) {
            messageElement.textContent = '';
            messageElement.classList.remove('is-visible');
        }
    }

    function clearFieldErrors(fields) {
        if (!fields) {
            return;
        }

        fields.forEach(function (field) {
            if (field) {
                clearFieldError(field);
            }
        });
    }

    function validateRequiredField(field) {
        var label = field.dataset.label || field.name || 'この項目';
        var value = (field.value || '').trim();

        clearFieldError(field);

        if (value === '') {
            showFieldError(field, label + 'を入力してください。');
            return false;
        }

        return true;
    }

    function setupRequiredValidation(formSelector) {
        var form = typeof formSelector === 'string' ? document.querySelector(formSelector) : formSelector;

        if (!form) {
            return;
        }

        var requiredFields = form.querySelectorAll('.js-required');

        requiredFields.forEach(function (field) {
            field.addEventListener('blur', function () {
                validateRequiredField(field);
            });

            field.addEventListener('input', function () {
                if ((field.value || '').trim() !== '') {
                    clearFieldError(field);
                }
            });
        });
    }

    function validateRequiredFields(formSelector) {
        var form = typeof formSelector === 'string' ? document.querySelector(formSelector) : formSelector;

        if (!form) {
            return true;
        }

        var requiredFields = form.querySelectorAll('.js-required');
        var isValid = true;

        requiredFields.forEach(function (field) {
            var fieldValid = validateRequiredField(field);

            if (!fieldValid && isValid) {
                field.focus();
            }

            isValid = isValid && fieldValid;
        });

        return isValid;
    }

    window.CommonValidation = {
        setupRequiredValidation: setupRequiredValidation,
        validateRequiredFields: validateRequiredFields,
        validateRequiredField: validateRequiredField,
        clearFieldError: clearFieldError,
        clearFieldErrors: clearFieldErrors,
        showFieldError: showFieldError
    };
})(window);